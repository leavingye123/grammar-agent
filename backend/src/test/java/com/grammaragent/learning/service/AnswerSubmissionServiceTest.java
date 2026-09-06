package com.grammaragent.learning.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.learning.entity.UserLearningProgress;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.repository.LearningProgressRepository;
import com.grammaragent.learning.repository.LessonProgressRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.dto.SubmitAnswerRequest;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.evaluator.QuestionAnswerEvaluator;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.repository.WrongQuestionRepository;
import com.grammaragent.question.service.QuestionContextService;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AnswerSubmissionServiceTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void repeatedWrongThenCorrectShouldAppendHistoryAndKeepWrongHistory() throws Exception {
        Lesson lesson = lesson();
        Question question = question();
        FakeQuestionRepository questionRepository = new FakeQuestionRepository(question);
        FakeUserAnswerRepository answerRepository = new FakeUserAnswerRepository();
        FakeLearningProgressRepository learningRepository = new FakeLearningProgressRepository();
        FakeWrongQuestionRepository wrongRepository = new FakeWrongQuestionRepository();
        FakeLessonProgressRepository lessonRepository = new FakeLessonProgressRepository();
        AnswerSubmissionService service = new AnswerSubmissionService(
                questionRepository,
                answerRepository,
                learningRepository,
                wrongRepository,
                lessonRepository,
                new QuestionAnswerEvaluator(),
                new FixedQuestionContextService(lesson),
                new MasteryCalculator());

        var wrong = service.submit(7L, 1L, request("B"));
        var correct = service.submit(7L, 1L, request("A"));

        assertFalse(wrong.correct());
        assertTrue(correct.correct());
        assertEquals(0, correct.xpEarned());
        assertEquals(50, correct.grammarPointMastery());
        assertEquals(2, answerRepository.answers.size());
        assertEquals(List.of(false, true), answerRepository.answers.stream().map(UserAnswer::getIsCorrect).toList());
        assertEquals(1, wrongRepository.wrongCounts.get(1L));
        assertEquals(2, learningRepository.progress.getTotalQuestions());
        assertEquals(1, learningRepository.progress.getCorrectQuestions());
        assertEquals(50, learningRepository.progress.getMasteryScore());
        assertEquals(LessonProgressStatus.IN_PROGRESS, lessonRepository.progress.getStatus());
        assertEquals(1, lessonRepository.progress.getCorrectCount());
        assertEquals(1, lessonRepository.progress.getTotalCount());
        assertEquals(0, lessonRepository.progress.getXpEarned());
    }

    private SubmitAnswerRequest request(String optionId) throws Exception {
        return new SubmitAnswerRequest(objectMapper.readTree("\"" + optionId + "\""), 100);
    }

    private Lesson lesson() {
        Lesson lesson = new Lesson();
        lesson.setId(10L);
        lesson.setGrammarPointId(100L);
        lesson.setXpReward(10);
        lesson.setEnabled(true);
        return lesson;
    }

    private Question question() throws Exception {
        Question question = new Question();
        question.setId(1L);
        question.setLessonId(10L);
        question.setGrammarPointId(100L);
        question.setQuestionType(QuestionType.SINGLE_CHOICE);
        question.setCorrectAnswer(objectMapper.readTree("{\"optionId\":\"A\"}"));
        question.setExplanation("Explanation");
        question.setEnabled(true);
        return question;
    }

    private static final class FakeQuestionRepository implements QuestionRepository {

        private final Question question;

        private FakeQuestionRepository(Question question) {
            this.question = question;
        }

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

    private static final class FakeUserAnswerRepository implements UserAnswerRepository {

        private final List<UserAnswer> answers = new ArrayList<>();

        @Override
        public void insert(UserAnswer userAnswer) {
            answers.add(userAnswer);
        }

        @Override
        public List<UserAnswer> findLatestByQuestionIds(Long userId, Collection<Long> questionIds) {
            Map<Long, UserAnswer> latest = new LinkedHashMap<>();
            for (int index = answers.size() - 1; index >= 0; index--) {
                UserAnswer answer = answers.get(index);
                if (answer.getUserId().equals(userId) && questionIds.contains(answer.getQuestionId())) {
                    latest.putIfAbsent(answer.getQuestionId(), answer);
                }
            }
            return List.copyOf(latest.values());
        }
    }

    private static final class FakeLearningProgressRepository implements LearningProgressRepository {

        private final MasteryCalculator calculator = new MasteryCalculator();
        private final UserLearningProgress progress = new UserLearningProgress();

        private FakeLearningProgressRepository() {
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
    }

    private static final class FakeWrongQuestionRepository implements WrongQuestionRepository {

        private final Map<Long, Integer> wrongCounts = new LinkedHashMap<>();

        @Override
        public void recordWrong(Long userId, Long questionId, OffsetDateTime wrongAt, OffsetDateTime nextReviewAt) {
            wrongCounts.merge(questionId, 1, Integer::sum);
        }

        @Override
        public List<com.grammaragent.question.entity.WrongQuestion> findDueByUserId(
                Long userId, OffsetDateTime now, int limit) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<com.grammaragent.question.entity.WrongQuestion> findUnmasteredByUserId(
                Long userId, int offset, int limit) {
            throw new UnsupportedOperationException();
        }

        @Override
        public com.grammaragent.question.repository.WrongQuestionSummary summarize(
                Long userId, OffsetDateTime now) {
            throw new UnsupportedOperationException();
        }

        @Override
        public Optional<com.grammaragent.question.entity.WrongQuestion> findForUpdate(
                Long userId, Long questionId) {
            return Optional.empty();
        }

        @Override
        public void updateReviewResult(
                com.grammaragent.question.entity.WrongQuestion wrongQuestion, OffsetDateTime updatedAt) {
            throw new UnsupportedOperationException();
        }
    }

    private static final class FakeLessonProgressRepository implements LessonProgressRepository {

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
}
