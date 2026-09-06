package com.grammaragent.question.evaluator;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.enums.QuestionType;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class QuestionAnswerEvaluatorTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final QuestionAnswerEvaluator evaluator = new QuestionAnswerEvaluator();

    @Test
    void shouldEvaluateSingleChoiceByOptionId() throws Exception {
        Question question = question(QuestionType.SINGLE_CHOICE, "{\"optionId\":\"A\"}");

        assertTrue(evaluator.evaluate(question, json("\"A\"")).correct());
        assertTrue(evaluator.evaluate(question, json("{\"optionId\":\"A\"}")).correct());
        assertFalse(evaluator.evaluate(question, json("\"B\"")).correct());
    }

    @Test
    void shouldEvaluateMultipleChoiceAsAnOrderIndependentSet() throws Exception {
        Question question = question(QuestionType.MULTIPLE_CHOICE, "{\"optionIds\":[\"A\",\"C\"]}");

        assertTrue(evaluator.evaluate(question, json("[\"C\",\"A\"]")).correct());
        assertFalse(evaluator.evaluate(question, json("[\"A\"]")).correct());
    }

    @Test
    void shouldNormalizeFillBlankCaseAndWhitespace() throws Exception {
        Question question = question(QuestionType.FILL_BLANK, "{\"answers\":[\"is\"]}");

        assertTrue(evaluator.evaluate(question, json("\"  IS  \"")).correct());
        assertFalse(evaluator.evaluate(question, json("\"are\"")).correct());
    }

    @Test
    void shouldKeepSentenceOrderStrict() throws Exception {
        Question question = question(
                QuestionType.SENTENCE_ORDER,
                "{\"tokens\":[\"They\",\"are\",\"friends\",\".\"]}");

        assertTrue(evaluator.evaluate(question, json("[\"They\",\"are\",\"friends\",\".\"]")).correct());
        assertFalse(evaluator.evaluate(question, json("[\"friends\",\"They\",\"are\",\".\"]")).correct());
    }

    @Test
    void shouldEvaluateTrueFalseAsStrictBoolean() throws Exception {
        Question question = question(QuestionType.TRUE_FALSE, "{\"value\":true}");

        assertTrue(evaluator.evaluate(question, json("true")).correct());
        assertFalse(evaluator.evaluate(question, json("false")).correct());
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> evaluator.evaluate(question, json("\"true\"")));
        assertEquals(ErrorCode.INVALID_ANSWER_FORMAT, exception.getErrorCode());
    }

    @Test
    void shouldNormalizeCorrectionWithoutFuzzyMatching() throws Exception {
        Question question = question(
                QuestionType.CORRECTION,
                "{\"acceptedAnswers\":[\"She is my teacher.\"]}");

        assertTrue(evaluator.evaluate(question, json("\"  SHE   is my teacher.  \"")).correct());
        assertFalse(evaluator.evaluate(question, json("\"She was my teacher.\"")).correct());
    }

    private Question question(QuestionType type, String correctAnswer) throws Exception {
        Question question = new Question();
        question.setQuestionType(type);
        question.setCorrectAnswer(json(correctAnswer));
        return question;
    }

    private JsonNode json(String value) throws Exception {
        return objectMapper.readTree(value);
    }
}
