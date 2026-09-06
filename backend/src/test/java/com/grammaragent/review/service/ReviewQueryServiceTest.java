package com.grammaragent.review.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.WrongQuestion;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.repository.WrongQuestionSummary;
import com.grammaragent.review.dto.ReviewQuestionResponse;
import com.grammaragent.review.dto.ReviewSummaryResponse;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

class ReviewQueryServiceTest {

    private static final Long USER_A = 7L;
    private static final Long USER_B = 8L;

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    @Test
    void dueShouldReturnOnlyCurrentUsersDueUnmasteredItemsWithoutAnswerLeakOrNPlusOne() throws Exception {
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        InMemoryWrongQuestionRepository wrongRepository = new InMemoryWrongQuestionRepository(List.of(
                wrong(1L, USER_A, 1L, 3, false, now.minusHours(2)),
                wrong(2L, USER_A, 2L, 2, false, now.plusHours(2)),
                wrong(3L, USER_A, 3L, 4, true, now.minusHours(3)),
                wrong(4L, USER_B, 4L, 5, false, now.minusHours(4))));
        CountingQuestionRepository questionRepository = new CountingQuestionRepository(List.of(
                question(1L), question(2L), question(3L), question(4L)));
        ReviewQueryService service = new ReviewQueryService(wrongRepository, questionRepository);

        List<ReviewQuestionResponse> result = service.getDue(USER_A, 20);

        assertThat(result).extracting(item -> item.question().id()).containsExactly(1L);
        assertThat(questionRepository.batchCalls).isEqualTo(1);
        String json = objectMapper.writeValueAsString(result);
        assertThat(json).doesNotContain("correctAnswer", "explanation", "secret");
    }

    @Test
    void unmasteredAndSummaryShouldBeUserScopedAndIncludeFutureItems() {
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        OffsetDateTime dueAt = now.minusHours(2);
        OffsetDateTime futureAt = now.plusHours(2);
        InMemoryWrongQuestionRepository wrongRepository = new InMemoryWrongQuestionRepository(List.of(
                wrong(1L, USER_A, 1L, 2, false, dueAt),
                wrong(2L, USER_A, 2L, 5, false, futureAt),
                wrong(3L, USER_A, 3L, 6, true, now.minusDays(1)),
                wrong(4L, USER_B, 4L, 9, false, dueAt)));
        ReviewQueryService service = new ReviewQueryService(
                wrongRepository,
                new CountingQuestionRepository(List.of(question(1L), question(2L), question(3L), question(4L))));

        List<ReviewQuestionResponse> wrongQuestions = service.getUnmastered(USER_A, 1, 20);
        ReviewSummaryResponse summary = service.getSummary(USER_A);

        assertThat(wrongQuestions).extracting(item -> item.question().id()).containsExactly(2L, 1L);
        assertThat(summary.dueCount()).isEqualTo(1);
        assertThat(summary.unmasteredCount()).isEqualTo(2);
        assertThat(summary.masteredCount()).isEqualTo(1);
        assertThat(summary.nextReviewAt()).isEqualTo(dueAt);
    }

    private Question question(Long id) {
        Question question = new Question();
        question.setId(id);
        question.setLessonId(10L);
        question.setGrammarPointId(100L);
        question.setQuestionType(QuestionType.SINGLE_CHOICE);
        question.setQuestionContent("Question " + id);
        question.setOptions(objectMapper.createArrayNode().add("A").add("B"));
        question.setCorrectAnswer(objectMapper.createObjectNode().put("optionId", "A"));
        question.setExplanation("secret");
        question.setDifficulty(1);
        question.setSortOrder(id.intValue());
        question.setEnabled(true);
        return question;
    }

    private WrongQuestion wrong(
            Long id,
            Long userId,
            Long questionId,
            int wrongCount,
            boolean mastered,
            OffsetDateTime nextReviewAt) {
        WrongQuestion item = new WrongQuestion();
        item.setId(id);
        item.setUserId(userId);
        item.setQuestionId(questionId);
        item.setWrongCount(wrongCount);
        item.setMastered(mastered);
        item.setLastWrongAt(nextReviewAt.minusDays(1));
        item.setNextReviewAt(nextReviewAt);
        return item;
    }

    private static final class CountingQuestionRepository implements QuestionRepository {

        private final List<Question> questions;
        private int batchCalls;

        private CountingQuestionRepository(List<Question> questions) {
            this.questions = questions;
        }

        @Override
        public Optional<Question> findEnabledById(Long questionId) {
            return questions.stream().filter(question -> question.getId().equals(questionId)).findFirst();
        }

        @Override
        public List<Question> findEnabledByIds(Collection<Long> questionIds) {
            batchCalls++;
            return questions.stream().filter(question -> questionIds.contains(question.getId())).toList();
        }

        @Override
        public List<Question> findEnabledByLessonId(Long lessonId) {
            return questions.stream().filter(question -> question.getLessonId().equals(lessonId)).toList();
        }
    }

    private static final class InMemoryWrongQuestionRepository implements WrongQuestionRepository {

        private final List<WrongQuestion> items;

        private InMemoryWrongQuestionRepository(List<WrongQuestion> items) {
            this.items = new ArrayList<>(items);
        }

        @Override
        public void recordWrong(Long userId, Long questionId, OffsetDateTime wrongAt, OffsetDateTime nextReviewAt) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<WrongQuestion> findDueByUserId(Long userId, OffsetDateTime now, int limit) {
            return items.stream()
                    .filter(item -> item.getUserId().equals(userId))
                    .filter(item -> !item.getMastered())
                    .filter(item -> item.getNextReviewAt() != null && !item.getNextReviewAt().isAfter(now))
                    .sorted(Comparator.comparing(WrongQuestion::getNextReviewAt)
                            .thenComparing(WrongQuestion::getWrongCount, Comparator.reverseOrder())
                            .thenComparing(WrongQuestion::getId))
                    .limit(limit)
                    .toList();
        }

        @Override
        public List<WrongQuestion> findUnmasteredByUserId(Long userId, int offset, int limit) {
            return items.stream()
                    .filter(item -> item.getUserId().equals(userId))
                    .filter(item -> !item.getMastered())
                    .sorted(Comparator.comparing(WrongQuestion::getWrongCount).reversed()
                            .thenComparing(WrongQuestion::getNextReviewAt)
                            .thenComparing(WrongQuestion::getId))
                    .skip(offset)
                    .limit(limit)
                    .toList();
        }

        @Override
        public WrongQuestionSummary summarize(Long userId, OffsetDateTime now) {
            List<WrongQuestion> own = items.stream().filter(item -> item.getUserId().equals(userId)).toList();
            WrongQuestionSummary summary = new WrongQuestionSummary();
            summary.setDueCount(own.stream()
                    .filter(item -> !item.getMastered())
                    .filter(item -> !item.getNextReviewAt().isAfter(now))
                    .count());
            summary.setUnmasteredCount(own.stream().filter(item -> !item.getMastered()).count());
            summary.setMasteredCount(own.stream().filter(WrongQuestion::getMastered).count());
            summary.setNextReviewAt(own.stream()
                    .filter(item -> !item.getMastered())
                    .map(WrongQuestion::getNextReviewAt)
                    .min(Comparator.naturalOrder())
                    .orElse(null));
            return summary;
        }

        @Override
        public Optional<WrongQuestion> findForUpdate(Long userId, Long questionId) {
            return Optional.empty();
        }

        @Override
        public void updateReviewResult(WrongQuestion wrongQuestion, OffsetDateTime updatedAt) {
            throw new UnsupportedOperationException();
        }
    }
}
