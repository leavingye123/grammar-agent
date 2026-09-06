package com.grammaragent.learning.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.learning.entity.LessonAttempt;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.dto.SubmitAnswerRequest;
import com.grammaragent.question.dto.SubmitAnswerResponse;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.evaluator.AnswerEvaluationResult;
import com.grammaragent.question.evaluator.QuestionAnswerEvaluator;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.service.QuestionContextService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnswerSubmissionService {

    private static final int ANSWER_XP_EARNED = 0;

    private final QuestionRepository questionRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final LearningProgressRepository learningProgressRepository;
    private final WrongQuestionRepository wrongQuestionRepository;
    private final LessonProgressRepository lessonProgressRepository;
    private final LessonAttemptRepository lessonAttemptRepository;
    private final QuestionAnswerEvaluator answerEvaluator;
    private final QuestionContextService contextService;
    private final MasteryCalculator masteryCalculator;

    @Transactional
    public SubmitAnswerResponse submit(Long userId, Long questionId, SubmitAnswerRequest request) {
        if (request.answer() == null || request.answer().isNull()) {
            throw new BusinessException(ErrorCode.INVALID_ANSWER_FORMAT);
        }

        Question question = questionRepository.findEnabledById(questionId)
                .orElseThrow(() -> new BusinessException(ErrorCode.QUESTION_NOT_FOUND));
        Lesson lesson = contextService.requireEnabledLesson(question.getLessonId());
        contextService.validateQuestion(question, lesson);
        AnswerEvaluationResult evaluation = answerEvaluator.evaluate(question, request.answer());
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);

        LessonAttempt attempt = lessonAttemptRepository.findOrCreateActive(userId, lesson.getId(), now);

        UserAnswer userAnswer = new UserAnswer();
        userAnswer.setUserId(userId);
        userAnswer.setQuestionId(question.getId());
        userAnswer.setLessonAttemptId(attempt.getId());
        userAnswer.setAnswer(request.answer().deepCopy());
        userAnswer.setIsCorrect(evaluation.correct());
        userAnswer.setDurationMs(request.durationMs());
        userAnswer.setAnsweredAt(now);
        userAnswerRepository.insert(userAnswer);

        if (!evaluation.correct()) {
            // Keep the same aggregate lock order as Review: wrong question first, learning progress second.
            wrongQuestionRepository.recordWrong(userId, question.getId(), now, now.plusDays(1));
        }
        UserLearningProgress learningProgress = learningProgressRepository.incrementAndGet(
                userId, question.getGrammarPointId(), evaluation.correct(), now);

        updateLessonProgress(userId, lesson, attempt.getId(), now);

        return new SubmitAnswerResponse(
                question.getId(),
                evaluation.correct(),
                question.getCorrectAnswer(),
                question.getExplanation(),
                ANSWER_XP_EARNED,
                learningProgress.getMasteryScore());
    }

    private void updateLessonProgress(Long userId, Lesson lesson, Long attemptId, OffsetDateTime now) {
        List<Question> questions = questionRepository.findEnabledByLessonId(lesson.getId());
        questions.forEach(question -> contextService.validateQuestion(question, lesson));
        List<UserAnswer> latestAnswers = userAnswerRepository.findLatestByQuestionIdsInAttempt(
                userId, questions.stream().map(Question::getId).toList(), attemptId);
        int correctCount = Math.toIntExact(latestAnswers.stream()
                .filter(answer -> Boolean.TRUE.equals(answer.getIsCorrect()))
                .count());
        int totalCount = questions.size();
        int score = masteryCalculator.calculate(correctCount, totalCount);
        lessonProgressRepository.upsert(
                userId,
                lesson.getId(),
                LessonProgressStatus.IN_PROGRESS,
                score,
                correctCount,
                totalCount,
                0,
                now);
    }
}
