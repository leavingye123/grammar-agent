package com.grammaragent.learning.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.learning.dto.LessonCompletionResponse;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.service.QuestionContextService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonCompletionService {

    private final QuestionRepository questionRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final LessonProgressRepository lessonProgressRepository;
    private final QuestionContextService contextService;
    private final MasteryCalculator masteryCalculator;

    @Transactional
    public LessonCompletionResponse complete(Long userId, Long lessonId) {
        Lesson lesson = contextService.requireEnabledLesson(lessonId);
        List<Question> questions = questionRepository.findEnabledByLessonId(lessonId);
        if (questions.isEmpty()) {
            throw new BusinessException(ErrorCode.LESSON_HAS_NO_QUESTIONS);
        }
        questions.forEach(question -> contextService.validateQuestion(question, lesson));

        List<UserAnswer> latestAnswers = userAnswerRepository.findLatestByQuestionIds(
                userId, questions.stream().map(Question::getId).toList());
        if (latestAnswers.size() != questions.size()) {
            throw new BusinessException(ErrorCode.LESSON_ANSWERS_INCOMPLETE);
        }

        int totalCount = questions.size();
        int correctCount = Math.toIntExact(latestAnswers.stream()
                .filter(answer -> Boolean.TRUE.equals(answer.getIsCorrect()))
                .count());
        int score = masteryCalculator.calculate(correctCount, totalCount);
        int xpEarned = calculateXp(lesson.getXpReward(), correctCount, totalCount);
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        lessonProgressRepository.upsert(
                userId,
                lessonId,
                LessonProgressStatus.COMPLETED,
                score,
                correctCount,
                totalCount,
                xpEarned,
                now);

        return new LessonCompletionResponse(
                lessonId,
                LessonProgressStatus.COMPLETED,
                totalCount,
                correctCount,
                score,
                xpEarned);
    }

    private int calculateXp(int lessonXpReward, int correctCount, int totalCount) {
        return Math.toIntExact((long) lessonXpReward * correctCount / totalCount);
    }
}
