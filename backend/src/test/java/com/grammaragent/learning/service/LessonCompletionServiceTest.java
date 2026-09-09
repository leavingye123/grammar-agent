package com.grammaragent.learning.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.learning.entity.LessonAttempt;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonAttemptStatus;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerCounts;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.service.QuestionContextService;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LessonCompletionServiceTest {

    @Test
    void shouldCompleteUsingLatestAnswerForEveryQuestion() {
        Fixtures fixtures = fixtures(List.of(
                answer(1L, true), answer(2L, true), answer(3L, true),
                answer(4L, true), answer(5L, false)));

        var result = fixtures.service.complete(7L, 10L);

        assertEquals(LessonProgressStatus.COMPLETED, result.status());
        assertEquals(fixtures.attempts.completed.getId(), result.lessonAttemptId());
        assertEquals(5, result.totalCount());
        assertEquals(4, result.correctCount());
        assertEquals(80, result.score());
        assertEquals(8, result.xpEarned());
        assertEquals(LessonProgressStatus.COMPLETED, fixtures.lessonProgress.progress.getStatus());
        assertEquals(8, fixtures.lessonProgress.progress.getXpEarned());
        assertEquals(LessonAttemptStatus.COMPLETED, fixtures.attempts.completed.getStatus());
        assertEquals(4, fixtures.attempts.completed.getCorrectCount());
        assertEquals(5, fixtures.attempts.completed.getTotalCount());
        assertEquals(80, fixtures.attempts.completed.getScore());
        assertEquals(8, fixtures.attempts.completed.getXpEarned());
        assertNotNull(fixtures.attempts.completed.getCompletedAt());
    }

    @Test
    void shouldRejectCompletionUntilEveryQuestionHasAnAnswer() {
        Fixtures fixtures = fixtures(List.of(answer(1L, true)));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> fixtures.service.complete(7L, 10L));

        assertEquals(ErrorCode.LESSON_ANSWERS_INCOMPLETE, exception.getErrorCode());
    }

    @Test
    void shouldRejectCompletionWithoutActiveAttempt() {
        Fixtures fixtures = fixtures(List.of(
                answer(1L, true), answer(2L, true), answer(3L, true),
                answer(4L, true), answer(5L, true)));
        fixtures.attempts.active = null;

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> fixtures.service.complete(7L, 10L));

        assertEquals(ErrorCode.LESSON_ANSWERS_INCOMPLETE, exception.getErrorCode());
    }

    @Test
    void shouldRejectEmptyLessonBeforeReadingAttemptOrUpdatingProgress() {
        Fixtures fixtures = fixtures(List.of(), List.of());

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> fixtures.service.complete(7L, 10L));

        assertEquals(ErrorCode.LESSON_HAS_NO_QUESTIONS, exception.getErrorCode());
        assertEquals(0, fixtures.attempts.activeLookupCount);
        assertEquals(0, fixtures.lessonProgress.upsertCount);
    }

    private Fixtures fixtures(List<UserAnswer> latestAnswers) {
        return fixtures(
                latestAnswers,
                List.of(question(1L), question(2L), question(3L), question(4L), question(5L)));
    }

    private Fixtures fixtures(List<UserAnswer> latestAnswers, List<Question> questions) {
        Lesson lesson = new Lesson();
        lesson.setId(10L);
        lesson.setGrammarPointId(100L);
        lesson.setXpReward(10);
        QuestionRepository questionRepository = new FixedQuestionRepository(questions);
        UserAnswerRepository userAnswerRepository = new FixedUserAnswerRepository(latestAnswers);
        CapturingLessonProgressRepository lessonProgress = new CapturingLessonProgressRepository();
        FakeLessonAttemptRepository attempts = new FakeLessonAttemptRepository();
        LessonCompletionService service = new LessonCompletionService(
                questionRepository,
                userAnswerRepository,
                lessonProgress,
                attempts,
                new FixedQuestionContextService(lesson),
                new MasteryCalculator());
        return new Fixtures(service, lessonProgress, attempts);
    }

    private Question question(Long id) {
        Question question = new Question();
        question.setId(id);
        question.setLessonId(10L);
        question.setGrammarPointId(100L);
        return question;
    }

    private UserAnswer answer(Long questionId, boolean correct) {
        UserAnswer answer = new UserAnswer();
        answer.setQuestionId(questionId);
        answer.setIsCorrect(correct);
        return answer;
    }

    private record FixedQuestionRepository(List<Question> questions) implements QuestionRepository {

        @Override
        public Optional<Question> findEnabledById(Long questionId) {
            return questions.stream().filter(question -> question.getId().equals(questionId)).findFirst();
        }

        @Override
        public List<Question> findEnabledByIds(Collection<Long> questionIds) {
            return questions.stream().filter(question -> questionIds.contains(question.getId())).toList();
        }

        @Override
        public List<Question> findEnabledByLessonId(Long lessonId) {
            return questions;
        }
    }

    private record FixedUserAnswerRepository(List<UserAnswer> answers) implements UserAnswerRepository {

        @Override
        public void insert(UserAnswer userAnswer) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<UserAnswer> findLatestByQuestionIdsInAttempt(
                Long userId, Collection<Long> questionIds, Long attemptId) {
            return answers;
        }

        @Override
        public UserAnswerCounts countByUser(Long userId) {
            throw new UnsupportedOperationException();
        }
    }

    private static final class CapturingLessonProgressRepository implements LessonProgressRepository {

        private final UserLessonProgress progress = new UserLessonProgress();
        private int upsertCount;

        @Override
        public void upsert(
                Long userId,
                Long lessonId,
                LessonProgressStatus status,
                int score,
                int correctCount,
                int totalCount,
                int xpEarned,
                OffsetDateTime now) {
            upsertCount++;
            progress.setUserId(userId);
            progress.setLessonId(lessonId);
            progress.setStatus(status);
            progress.setScore(score);
            progress.setCorrectCount(correctCount);
            progress.setTotalCount(totalCount);
            progress.setXpEarned(xpEarned);
        }

        @Override
        public Optional<UserLessonProgress> findByUserAndLesson(Long userId, Long lessonId) {
            return Optional.of(progress);
        }

        @Override
        public List<UserLessonProgress> findByUserId(Long userId) {
            return List.of(progress);
        }
    }

    private static final class FakeLessonAttemptRepository implements LessonAttemptRepository {

        private LessonAttempt active = attempt();
        private LessonAttempt completed;
        private int activeLookupCount;

        private static LessonAttempt attempt() {
            LessonAttempt attempt = new LessonAttempt();
            attempt.setId(99L);
            attempt.setUserId(7L);
            attempt.setLessonId(10L);
            attempt.setStatus(LessonAttemptStatus.IN_PROGRESS);
            return attempt;
        }

        @Override
        public LessonAttempt findOrCreateActive(Long userId, Long lessonId, OffsetDateTime now) {
            return active;
        }

        @Override
        public Optional<LessonAttempt> findActiveForUpdate(Long userId, Long lessonId) {
            activeLookupCount++;
            return Optional.ofNullable(active);
        }

        @Override
        public void complete(
                Long attemptId,
                int totalCount,
                int correctCount,
                int score,
                int xpEarned,
                OffsetDateTime completedAt) {
            completed = active;
            completed.setStatus(LessonAttemptStatus.COMPLETED);
            completed.setTotalCount(totalCount);
            completed.setCorrectCount(correctCount);
            completed.setScore(score);
            completed.setXpEarned(xpEarned);
            completed.setCompletedAt(completedAt);
        }

        @Override
        public List<LessonAttempt> findByUserAndLesson(Long userId, Long lessonId) {
            return completed == null ? List.of() : List.of(completed);
        }

        @Override
        public long countCompletedAfter(Long userId, OffsetDateTime since) {
            return 0;
        }

        @Override
        public long sumXpCompletedAfter(Long userId, OffsetDateTime since) {
            return 0;
        }

        @Override
        public long sumTotalCompletedXp(Long userId) {
            return 0;
        }
    }

    private static final class FixedQuestionContextService extends QuestionContextService {

        private final Lesson lesson;

        private FixedQuestionContextService(Lesson lesson) {
            super(null, null);
            this.lesson = lesson;
        }

        @Override
        public Lesson requireEnabledLesson(Long lessonId) {
            return lesson;
        }

        @Override
        public void validateQuestion(Question question, Lesson candidateLesson) {
            if (!question.getLessonId().equals(candidateLesson.getId())
                    || !question.getGrammarPointId().equals(candidateLesson.getGrammarPointId())) {
                throw new AssertionError("Invalid test question context");
            }
        }
    }

    private record Fixtures(
            LessonCompletionService service,
            CapturingLessonProgressRepository lessonProgress,
            FakeLessonAttemptRepository attempts
    ) {
    }
}
