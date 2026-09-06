package com.grammaragent.review.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.dto.SubmitAnswerRequest;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.entity.WrongQuestion;
import com.grammaragent.question.evaluator.AnswerEvaluationResult;
import com.grammaragent.question.evaluator.QuestionAnswerEvaluator;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.service.QuestionContextService;
import com.grammaragent.review.dto.ReviewAnswerResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

@Service
@RequiredArgsConstructor
public class ReviewAnswerService {

    private final QuestionRepository questionRepository;
    private final WrongQuestionRepository wrongQuestionRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final LearningProgressRepository learningProgressRepository;
    private final QuestionAnswerEvaluator answerEvaluator;
    private final QuestionContextService contextService;
    private final ReviewScheduler reviewScheduler;

    /**
     * An unmastered item may be reviewed early; the due time prioritizes the queue but does not lock it.
     */
    @Transactional
    public ReviewAnswerResponse submit(Long userId, Long questionId, SubmitAnswerRequest request) {
        Question question = questionRepository.findEnabledById(questionId)
                .orElseThrow(() -> new BusinessException(ErrorCode.QUESTION_NOT_FOUND));
        Lesson lesson = contextService.requireEnabledLesson(question.getLessonId());
        contextService.validateQuestion(question, lesson);

        WrongQuestion wrongQuestion = wrongQuestionRepository.findForUpdate(userId, questionId)
                .orElseThrow(() -> new BusinessException(ErrorCode.REVIEW_ITEM_NOT_FOUND));
        if (Boolean.TRUE.equals(wrongQuestion.getMastered())) {
            throw new BusinessException(ErrorCode.REVIEW_ITEM_ALREADY_MASTERED);
        }

        AnswerEvaluationResult evaluation = answerEvaluator.evaluate(question, request.answer());
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        userAnswerRepository.insert(toUserAnswer(userId, questionId, request, evaluation.correct(), now));
        UserLearningProgress progress = learningProgressRepository.incrementAndGet(
                userId, question.getGrammarPointId(), evaluation.correct(), now);

        if (evaluation.correct()) {
            wrongQuestion.setMastered(true);
            wrongQuestion.setNextReviewAt(null);
        } else {
            wrongQuestion.setWrongCount(wrongQuestion.getWrongCount() + 1);
            wrongQuestion.setLastWrongAt(now);
            wrongQuestion.setNextReviewAt(reviewScheduler.nextAfterIncorrect(now));
            wrongQuestion.setMastered(false);
        }
        wrongQuestionRepository.updateReviewResult(wrongQuestion, now);

        return new ReviewAnswerResponse(
                questionId,
                evaluation.correct(),
                question.getCorrectAnswer(),
                question.getExplanation(),
                wrongQuestion.getMastered(),
                wrongQuestion.getWrongCount(),
                wrongQuestion.getNextReviewAt(),
                progress.getMasteryScore());
    }

    private UserAnswer toUserAnswer(
            Long userId,
            Long questionId,
            SubmitAnswerRequest request,
            boolean correct,
            OffsetDateTime answeredAt) {
        UserAnswer answer = new UserAnswer();
        answer.setUserId(userId);
        answer.setQuestionId(questionId);
        answer.setAnswer(request.answer().deepCopy());
        answer.setIsCorrect(correct);
        answer.setDurationMs(request.durationMs());
        answer.setAnsweredAt(answeredAt);
        return answer;
    }
}
