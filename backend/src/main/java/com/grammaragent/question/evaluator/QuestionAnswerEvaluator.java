package com.grammaragent.question.evaluator;

import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.question.entity.Question;
import org.springframework.stereotype.Component;

import java.text.Normalizer;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.StreamSupport;

/**
 * Deterministic Stage 5 answer rules:
 * single choice compares one option id; multiple choice compares set membership;
 * fill-blank and correction answers use NFKC, trimmed, collapsed-whitespace,
 * case-insensitive text; sentence-order keeps token order significant; and
 * true/false accepts booleans only. No fuzzy or LLM-based grading is performed.
 */
@Component
public class QuestionAnswerEvaluator {

    public AnswerEvaluationResult evaluate(Question question, JsonNode submittedAnswer) {
        if (submittedAnswer == null || submittedAnswer.isNull()) {
            throw invalidAnswer();
        }

        boolean correct = switch (question.getQuestionType()) {
            case SINGLE_CHOICE -> evaluateSingleChoice(question.getCorrectAnswer(), submittedAnswer);
            case MULTIPLE_CHOICE -> evaluateMultipleChoice(question.getCorrectAnswer(), submittedAnswer);
            case FILL_BLANK -> evaluateFillBlank(question.getCorrectAnswer(), submittedAnswer);
            case SENTENCE_ORDER -> evaluateSentenceOrder(question.getCorrectAnswer(), submittedAnswer);
            case TRUE_FALSE -> evaluateTrueFalse(question.getCorrectAnswer(), submittedAnswer);
            case CORRECTION -> evaluateCorrection(question.getCorrectAnswer(), submittedAnswer);
        };
        return new AnswerEvaluationResult(correct);
    }

    private boolean evaluateSingleChoice(JsonNode expected, JsonNode submitted) {
        String expectedOption = textValue(expected, "optionId");
        String submittedOption = textValue(submitted, "optionId");
        return expectedOption.equals(submittedOption);
    }

    private boolean evaluateMultipleChoice(JsonNode expected, JsonNode submitted) {
        JsonNode expectedOptions = expected.isObject() ? expected.get("optionIds") : expected;
        JsonNode submittedOptions = submitted.isObject() ? submitted.get("optionIds") : submitted;
        return stringSet(expectedOptions).equals(stringSet(submittedOptions));
    }

    private boolean evaluateFillBlank(JsonNode expected, JsonNode submitted) {
        if (!submitted.isTextual()) {
            throw invalidAnswer();
        }
        JsonNode acceptedAnswers = expected.isObject() ? expected.get("answers") : expected;
        if (acceptedAnswers == null || !acceptedAnswers.isArray()) {
            throw invalidAnswer();
        }
        String normalizedSubmitted = normalizeFreeText(submitted.textValue());
        return StreamSupport.stream(acceptedAnswers.spliterator(), false)
                .map(this::requiredText)
                .map(this::normalizeFreeText)
                .anyMatch(normalizedSubmitted::equals);
    }

    private boolean evaluateSentenceOrder(JsonNode expected, JsonNode submitted) {
        JsonNode expectedTokens = expected.isObject() ? expected.get("tokens") : expected;
        JsonNode submittedTokens = submitted.isObject() ? submitted.get("tokens") : submitted;
        return stringList(expectedTokens).equals(stringList(submittedTokens));
    }

    private boolean evaluateTrueFalse(JsonNode expected, JsonNode submitted) {
        JsonNode expectedValue = expected.isObject() ? expected.get("value") : expected;
        JsonNode submittedValue = submitted.isObject() ? submitted.get("value") : submitted;
        if (expectedValue == null || submittedValue == null
                || !expectedValue.isBoolean() || !submittedValue.isBoolean()) {
            throw invalidAnswer();
        }
        return expectedValue.booleanValue() == submittedValue.booleanValue();
    }

    private boolean evaluateCorrection(JsonNode expected, JsonNode submitted) {
        if (!submitted.isTextual()) {
            throw invalidAnswer();
        }
        JsonNode acceptedAnswers = expected.isObject() ? expected.get("acceptedAnswers") : expected;
        if (acceptedAnswers == null || !acceptedAnswers.isArray()) {
            throw invalidAnswer();
        }
        String normalizedSubmitted = normalizeFreeText(submitted.textValue());
        return StreamSupport.stream(acceptedAnswers.spliterator(), false)
                .map(this::requiredText)
                .map(this::normalizeFreeText)
                .anyMatch(normalizedSubmitted::equals);
    }

    private String textValue(JsonNode node, String objectField) {
        JsonNode value = node != null && node.isObject() ? node.get(objectField) : node;
        return requiredText(value).trim();
    }

    private Set<String> stringSet(JsonNode node) {
        return new HashSet<>(stringList(node));
    }

    private List<String> stringList(JsonNode node) {
        if (node == null || !node.isArray()) {
            throw invalidAnswer();
        }
        return StreamSupport.stream(node.spliterator(), false)
                .map(this::requiredText)
                .map(String::trim)
                .toList();
    }

    private String requiredText(JsonNode node) {
        if (node == null || !node.isTextual()) {
            throw invalidAnswer();
        }
        return node.textValue();
    }

    private String normalizeFreeText(String value) {
        return Normalizer.normalize(value, Normalizer.Form.NFKC)
                .trim()
                .replaceAll("\\s+", " ")
                .toLowerCase(Locale.ROOT);
    }

    private BusinessException invalidAnswer() {
        return new BusinessException(ErrorCode.INVALID_ANSWER_FORMAT);
    }
}
