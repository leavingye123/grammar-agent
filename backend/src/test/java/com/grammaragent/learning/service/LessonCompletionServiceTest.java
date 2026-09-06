package com.grammaragent.learning.service;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.service.QuestionContextService;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LessonCompletionServiceTest {

    @Test
    void shouldCompleteUsingLatestAnswerForEveryQuestion() {
        Fixtures fixtures = fixtures(List.of(
                answer(1L, true), answer(2L, true), answer(3L, true),
                answer(4L, true), answer(5L, false)));

        var result = fixtures.service.complete(7L, 10L);

        assertEquals(LessonProgressStatus.COMPLETED, result.status());
        assertEquals(5, result.totalCount());
        assertEquals(4, result.correctCount());
        assertEquals(80, result.score());
        assertEquals(8, result.xpEarned());
        assertEquals(LessonProgressStatus.COMPLETED, fixtures.lessonProgress.progress.getStatus());
        assertEquals(8, fixtures.lessonProgress.progress.getXpEarned());
    }

    @Test
    void shouldRejectCompletionUntilEveryQuestionHasAnAnswer() {
        Fixtures fixtures = fixtures(List.of(answer(1L, true)));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> fixtures.service.complete(7L, 10L));

        assertEquals(ErrorCode.LESSON_ANSWERS_INCOMPLETE, exception.getErrorCode());
    }

    private Fixtures fixtures(List<UserAnswer> latestAnswers) {
        Lesson lesson = new Lesson();
        lesson.setId(10L);
        lesson.setGrammarPointId(100L);
        lesson.setXpReward(10);
        List<Question> questions = List.of(question(1L), question(2L), question(3L), question(4L), question(5L));
        QuestionRepository questionRepository = new FixedQuestionRepository(questions);
        UserAnswerRepository userAnswerRepository = new FixedUserAnswerRepository(latestAnswers);
        CapturingLessonProgressRepository lessonProgress = new CapturingLessonProgressRepository();
        LessonCompletionService service = new LessonCompletionService(
                questionRepository,
                userAnswerRepository,
                lessonProgress,
                new FixedQuestionContextService(lesson),
                new MasteryCalculator());
        return new Fixtures(service, lessonProgress);
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
        public List<UserAnswer> findLatestByQuestionIds(Long userId, Collection<Long> questionIds) {
            return answers;
        }
    }

    private static final class CapturingLessonProgressRepository implements LessonProgressRepository {

        private final UserLessonProgress progress = new UserLessonProgress();

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
            CapturingLessonProgressRepository lessonProgress
    ) {
    }
}
