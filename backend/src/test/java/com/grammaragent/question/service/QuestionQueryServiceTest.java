package com.grammaragent.question.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.repository.QuestionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class QuestionQueryServiceTest {

    @Test
    void shouldReturnSortedSafeQuestionResponses() throws Exception {
        Lesson lesson = new Lesson();
        lesson.setId(10L);
        lesson.setGrammarPointId(100L);
        Question second = question(2L, 2);
        Question first = question(1L, 1);
        QuestionRepository repository = new FixedQuestionRepository(List.of(second, first));
        QuestionContextService contextService = new FixedQuestionContextService(lesson);

        var response = new QuestionQueryService(repository, contextService).getLessonQuestions(10L);

        assertEquals(List.of(1L, 2L), response.stream().map(item -> item.id()).toList());
        assertEquals(List.of("A1-001-Q001", "A1-001-Q002"),
                response.stream().map(item -> item.questionCode()).toList());
        String json = new ObjectMapper().writeValueAsString(response);
        assertFalse(json.contains("correctAnswer"));
        assertFalse(json.contains("explanation"));
        assertFalse(json.contains("userId"));
    }

    private Question question(Long id, int sortOrder) throws Exception {
        Question question = new Question();
        question.setId(id);
        question.setQuestionCode("A1-001-Q00" + id);
        question.setLessonId(10L);
        question.setGrammarPointId(100L);
        question.setQuestionType(QuestionType.SINGLE_CHOICE);
        question.setQuestionContent("Question " + id);
        question.setOptions(new ObjectMapper().readTree("[\"A\",\"B\"]"));
        question.setCorrectAnswer(new ObjectMapper().readTree("{\"optionId\":\"A\"}"));
        question.setExplanation("secret explanation");
        question.setDifficulty(1);
        question.setSortOrder(sortOrder);
        question.setEnabled(true);
        return question;
    }

    private record FixedQuestionRepository(List<Question> questions) implements QuestionRepository {

        @Override
        public Optional<Question> findEnabledById(Long questionId) {
            return questions.stream().filter(question -> question.getId().equals(questionId)).findFirst();
        }

        @Override
        public List<Question> findEnabledByIds(java.util.Collection<Long> questionIds) {
            return questions.stream().filter(question -> questionIds.contains(question.getId())).toList();
        }

        @Override
        public List<Question> findEnabledByLessonId(Long lessonId) {
            return questions;
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
