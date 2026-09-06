package com.grammaragent.review.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.service.MasteryCalculator;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.dto.SubmitAnswerRequest;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.entity.WrongQuestion;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.evaluator.QuestionAnswerEvaluator;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.repository.WrongQuestionSummary;
import com.grammaragent.question.service.QuestionContextService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ReviewAnswerServiceTest {

    private static final Long USER_A = 7L;
    private static final Long USER_B = 8L;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private Question question;
    private InMemoryWrongQuestionRepository wrongRepository;
    private CapturingUserAnswerRepository answerRepository;
    private InMemoryLearningProgressRepository learningRepository;
    private ReviewAnswerService service;

    @BeforeEach
    void setUp() {
        question = question();
        wrongRepository = new InMemoryWrongQuestionRepository();
        answerRepository = new CapturingUserAnswerRepository();
        learningRepository = new InMemoryLearningProgressRepository();
        service = new ReviewAnswerService(
                new FixedQuestionRepository(question),
                wrongRepository,
                answerRepository,
                learningRepository,
                new QuestionAnswerEvaluator(),
                new FixedQuestionContextService(lesson()),
                new ReviewScheduler());
    }

    @Test
    void correctReviewShouldAppendAnswerUpdateMasteryAndMasterItemWithoutChangingWrongCount() {
        WrongQuestion item = wrong(USER_A, 2);
        wrongRepository.item = item;

        var response = service.submit(USER_A, question.getId(), request("A", 2300));

        assertThat(response.correct()).isTrue();
        assertThat(response.mastered()).isTrue();
        assertThat(response.wrongCount()).isEqualTo(2);
        assertThat(response.nextReviewAt()).isNull();
        assertThat(response.correctAnswer()).isEqualTo(question.getCorrectAnswer());
        assertThat(response.explanation()).isEqualTo("Explanation");
        assertThat(response.grammarPointMastery()).isEqualTo(100);
        assertThat(item.getMastered()).isTrue();
        assertThat(answerRepository.answers).hasSize(1);
        assertThat(answerRepository.answers.getFirst().getUserId()).isEqualTo(USER_A);
        assertThat(answerRepository.answers.getFirst().getDurationMs()).isEqualTo(2300);
        assertThat(answerRepository.answers.getFirst().getIsCorrect()).isTrue();
        assertThat(answerRepository.answers.getFirst().getLessonAttemptId()).isNull();
        assertThat(learningRepository.progress.getTotalQuestions()).isEqualTo(1);
        assertThat(learningRepository.progress.getCorrectQuestions()).isEqualTo(1);
    }

    @Test
    void incorrectReviewShouldIncrementWrongCountAndScheduleOneDayLater() {
        WrongQuestion item = wrong(USER_A, 2);
        wrongRepository.item = item;
        OffsetDateTime before = OffsetDateTime.now(ZoneOffset.UTC).plusDays(1).minusSeconds(1);

        var response = service.submit(USER_A, question.getId(), request("B", 1500));

        OffsetDateTime after = OffsetDateTime.now(ZoneOffset.UTC).plusDays(1).plusSeconds(1);
        assertThat(response.correct()).isFalse();
        assertThat(response.mastered()).isFalse();
        assertThat(response.wrongCount()).isEqualTo(3);
        assertThat(response.nextReviewAt()).isBetween(before, after);
        assertThat(item.getLastWrongAt()).isBetween(before.minusDays(1), after.minusDays(1));
        assertThat(answerRepository.answers).hasSize(1);
        assertThat(learningRepository.progress.getTotalQuestions()).isEqualTo(1);
        assertThat(learningRepository.progress.getCorrectQuestions()).isZero();
        assertThat(learningRepository.progress.getMasteryScore()).isZero();
    }

    @Test
    void masteredItemShouldRejectBeforeWritingAnswerOrProgress() {
        WrongQuestion item = wrong(USER_A, 2);
        item.setMastered(true);
        wrongRepository.item = item;

        assertThatThrownBy(() -> service.submit(USER_A, question.getId(), request("A", 100)))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.REVIEW_ITEM_ALREADY_MASTERED));
        assertThat(answerRepository.answers).isEmpty();
        assertThat(learningRepository.progress.getTotalQuestions()).isZero();
        assertThat(wrongRepository.updateCount).isZero();
    }

    @Test
    void userCannotReviewAnotherUsersItemOrQuestionNeverAddedToWrongQuestions() {
        wrongRepository.item = wrong(USER_B, 1);

        assertThatThrownBy(() -> service.submit(USER_A, question.getId(), request("A", 100)))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.REVIEW_ITEM_NOT_FOUND));
        wrongRepository.item = null;
        assertThatThrownBy(() -> service.submit(USER_A, question.getId(), request("A", 100)))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.REVIEW_ITEM_NOT_FOUND));
        assertThat(answerRepository.answers).isEmpty();
    }

    private SubmitAnswerRequest request(String optionId, int durationMs) {
        return new SubmitAnswerRequest(objectMapper.getNodeFactory().textNode(optionId), durationMs);
    }

    private Lesson lesson() {
        Lesson lesson = new Lesson();
        lesson.setId(10L);
        lesson.setGrammarPointId(100L);
        lesson.setEnabled(true);
        return lesson;
    }

    private Question question() {
        Question value = new Question();
        value.setId(1L);
        value.setLessonId(10L);
        value.setGrammarPointId(100L);
        value.setQuestionType(QuestionType.SINGLE_CHOICE);
        value.setCorrectAnswer(objectMapper.createObjectNode().put("optionId", "A"));
        value.setExplanation("Explanation");
        value.setEnabled(true);
        return value;
    }

    private WrongQuestion wrong(Long userId, int wrongCount) {
        WrongQuestion item = new WrongQuestion();
        item.setId(50L);
        item.setUserId(userId);
        item.setQuestionId(question.getId());
        item.setWrongCount(wrongCount);
        item.setLastWrongAt(OffsetDateTime.now(ZoneOffset.UTC).minusDays(1));
        item.setNextReviewAt(OffsetDateTime.now(ZoneOffset.UTC));
        item.setMastered(false);
        return item;
    }

    private record FixedQuestionRepository(Question question) implements QuestionRepository {

        @Override
        public Optional<Question> findEnabledById(Long questionId) {
            return question.getId().equals(questionId) ? Optional.of(question) : Optional.empty();
        }

        @Override
        public List<Question> findEnabledByIds(Collection<Long> questionIds) {
            return questionIds.contains(question.getId()) ? List.of(question) : List.of();
        }

        @Override
        public List<Question> findEnabledByLessonId(Long lessonId) {
            return List.of(question);
        }
    }

    private static final class InMemoryWrongQuestionRepository implements WrongQuestionRepository {

        private WrongQuestion item;
        private int updateCount;

        @Override
        public void recordWrong(Long userId, Long questionId, OffsetDateTime wrongAt, OffsetDateTime nextReviewAt) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<WrongQuestion> findDueByUserId(Long userId, OffsetDateTime now, int limit) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<WrongQuestion> findUnmasteredByUserId(Long userId, int offset, int limit) {
            throw new UnsupportedOperationException();
        }

        @Override
        public WrongQuestionSummary summarize(Long userId, OffsetDateTime now) {
            throw new UnsupportedOperationException();
        }

        @Override
        public Optional<WrongQuestion> findForUpdate(Long userId, Long questionId) {
            if (item == null || !item.getUserId().equals(userId) || !item.getQuestionId().equals(questionId)) {
                return Optional.empty();
            }
            return Optional.of(item);
        }

        @Override
        public void updateReviewResult(WrongQuestion wrongQuestion, OffsetDateTime updatedAt) {
            updateCount++;
            item = wrongQuestion;
        }
    }

    private static final class CapturingUserAnswerRepository implements UserAnswerRepository {

        private final List<UserAnswer> answers = new ArrayList<>();

        @Override
        public void insert(UserAnswer userAnswer) {
            answers.add(userAnswer);
        }

        @Override
        public List<UserAnswer> findLatestByQuestionIdsInAttempt(
                Long userId, Collection<Long> questionIds, Long attemptId) {
            return List.of();
        }

        @Override
        public com.grammaragent.question.repository.UserAnswerCounts countByUser(Long userId) {
            throw new UnsupportedOperationException();
        }
    }

    private static final class InMemoryLearningProgressRepository implements LearningProgressRepository {

        private final UserLearningProgress progress = new UserLearningProgress();
        private final MasteryCalculator calculator = new MasteryCalculator();

        private InMemoryLearningProgressRepository() {
            progress.setTotalQuestions(0);
            progress.setCorrectQuestions(0);
            progress.setMasteryScore(0);
        }

        @Override
        public UserLearningProgress incrementAndGet(
                Long userId, Long grammarPointId, boolean correct, OffsetDateTime studiedAt) {
            int total = progress.getTotalQuestions() + 1;
            int correctCount = progress.getCorrectQuestions() + (correct ? 1 : 0);
            progress.setUserId(userId);
            progress.setGrammarPointId(grammarPointId);
            progress.setTotalQuestions(total);
            progress.setCorrectQuestions(correctCount);
            progress.setMasteryScore(calculator.calculate(correctCount, total));
            progress.setLastStudyAt(studiedAt);
            return progress;
        }

        @Override
        public List<UserLearningProgress> findByUserId(Long userId) {
            return List.of(progress);
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
}
