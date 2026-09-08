package com.grammaragent.content;

import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.content.model.ContentReviewStatus;
import com.grammaragent.content.model.CurriculumContent;
import com.grammaragent.content.model.QuestionProvenance;
import com.grammaragent.question.enums.QuestionType;
import org.springframework.stereotype.Component;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

/** Lightweight deterministic checks for fixed question content; this is not NLP. */
@Component
public class QuestionContentValidator {

    private static final Pattern QUESTION_CODE = Pattern.compile("[A-Z][0-9]-\\d{3}-Q\\d{3}");
    private static final Pattern ADVANCED_WORDS = Pattern.compile(
            "(?i)\\b(nevertheless|notwithstanding|consequently|whereas|hypothetical|subsequently)\\b");
    private static final Pattern COMMON_NAMES = Pattern.compile(
            "(?i)\\b(tom|anna|mia|leo|lina|noah|mary|john)\\b");

    public QualityReport inspect(CurriculumContent content) {
        List<String> errors = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        Set<String> codes = new HashSet<>();
        Map<String, String> exactSignatures = new HashMap<>();
        Map<String, String> normalizedSignatures = new HashMap<>();
        Map<String, String> nameVariantSignatures = new HashMap<>();
        int questionCount = 0;
        int explanationMissing = 0;
        int aiDraftCount = 0;
        int reviewRequired = 0;
        int approvedCount = 0;
        int exactDuplicates = 0;
        int normalizedDuplicates = 0;
        int mechanicalNameVariants = 0;
        int microLessonCount = 0;
        int quickCheckCount = 0;
        int readyLessonCount = 0;
        int comingSoonLessonCount = 0;

        for (var chapter : content.chapters()) {
            for (var point : chapter.grammarPoints()) {
                if (point.microLesson() != null) {
                    microLessonCount++;
                    if (point.microLesson().quickCheck() != null) {
                        quickCheckCount += point.microLesson().quickCheck().size();
                    }
                }
                for (var lesson : point.lessons()) {
                    if (lesson.questions().isEmpty()) {
                        comingSoonLessonCount++;
                    } else {
                        readyLessonCount++;
                    }
                    for (var question : lesson.questions()) {
                        questionCount++;
                        String code = question.questionCode();
                        if (code == null || !QUESTION_CODE.matcher(code).matches()
                                || !code.startsWith(point.code() + "-Q")) {
                            errors.add(point.code() + " has invalid question code " + code);
                        } else if (!codes.add(code)) {
                            errors.add("Duplicate question code " + code);
                        }
                        if (question.questionContent() == null || question.questionContent().trim().length() < 8) {
                            errors.add(code + " has an empty or meaningless prompt");
                        }
                        if (question.explanation() == null || question.explanation().trim().length() < 8) {
                            explanationMissing++;
                            errors.add(code + " has a missing or too-short explanation");
                        }
                        if (question.provenance() == null || question.reviewStatus() == null) {
                            errors.add(code + " has no provenance or review status");
                        }
                        if (question.provenance() == QuestionProvenance.AI_DRAFT
                                && question.reviewStatus() == ContentReviewStatus.APPROVED) {
                            errors.add(code + " cannot be APPROVED while its provenance is AI_DRAFT");
                        }
                        if (question.provenance() == QuestionProvenance.AI_DRAFT) {
                            aiDraftCount++;
                        }
                        if (question.reviewStatus() == ContentReviewStatus.REVIEW_REQUIRED) {
                            reviewRequired++;
                        }
                        if (question.reviewStatus() == ContentReviewStatus.APPROVED) {
                            approvedCount++;
                        }
                        if (question.difficulty() < 1 || question.difficulty() > 5) {
                            errors.add(code + " has invalid difficulty");
                        }
                        validateAnswerShape(question, errors);
                        if (ADVANCED_WORDS.matcher(question.questionContent()).find()) {
                            warnings.add(code + " may contain vocabulary above A1");
                        }

                        String exact = signature(question, false);
                        if (exactSignatures.putIfAbsent(exact, code) != null) {
                            exactDuplicates++;
                            errors.add(code + " exactly duplicates " + exactSignatures.get(exact));
                        }
                        String normalized = signature(question, true);
                        if (normalizedSignatures.putIfAbsent(normalized, code) != null) {
                            normalizedDuplicates++;
                            errors.add(code + " normalized-duplicates " + normalizedSignatures.get(normalized));
                        }
                        String nameVariant = COMMON_NAMES.matcher(normalized).replaceAll("<name>");
                        String previous = nameVariantSignatures.putIfAbsent(nameVariant, code);
                        if (previous != null && !normalized.equals(signatureByCode(content, previous))) {
                            mechanicalNameVariants++;
                            warnings.add(code + " may be a name-only variant of " + previous);
                        }
                    }
                }
            }
        }
        return new QualityReport(
                questionCount,
                List.copyOf(errors),
                List.copyOf(warnings),
                exactDuplicates,
                normalizedDuplicates,
                mechanicalNameVariants,
                explanationMissing,
                aiDraftCount,
                reviewRequired,
                approvedCount,
                microLessonCount,
                quickCheckCount,
                readyLessonCount,
                comingSoonLessonCount);
    }

    public QualityReport validate(CurriculumContent content) {
        QualityReport report = inspect(content);
        if (!report.errors().isEmpty()) {
            throw new IllegalStateException("Invalid question content:\n- " + String.join("\n- ", report.errors()));
        }
        return report;
    }

    private void validateAnswerShape(
            CurriculumContent.QuestionContent question,
            List<String> errors) {
        String code = question.questionCode();
        JsonNode answer = question.correctAnswer();
        if (answer == null || answer.isNull()) {
            errors.add(code + " has no correct answer");
            return;
        }
        if (question.questionType() == null) {
            errors.add(code + " has no question type");
            return;
        }
        switch (question.questionType()) {
            case SINGLE_CHOICE -> validateChoice(question, "optionId", false, errors);
            case MULTIPLE_CHOICE -> validateChoice(question, "optionIds", true, errors);
            case TRUE_FALSE -> {
                if (!answer.path("value").isBoolean()) {
                    errors.add(code + " true/false answer must contain a boolean value");
                }
                JsonNode options = question.options();
                if (options == null || !options.isArray() || options.size() != 2
                        || !StreamSupport.stream(options.spliterator(), false)
                        .map(option -> option.get("value"))
                        .filter(value -> value != null && value.isBoolean())
                        .map(JsonNode::booleanValue)
                        .collect(Collectors.toSet())
                        .equals(Set.of(true, false))) {
                    errors.add(code + " true/false options must contain one true and one false value");
                }
            }
            case SENTENCE_ORDER -> {
                List<String> options = stringValues(question.options());
                List<String> tokens = stringValues(answer.get("tokens"));
                if (options.isEmpty() || tokens.isEmpty()
                        || !frequency(options).equals(frequency(tokens))) {
                    errors.add(code + " sentence-order tokens do not match options");
                }
            }
            case FILL_BLANK -> validateTextAnswers(code, answer.get("answers"), errors);
            case CORRECTION -> validateTextAnswers(code, answer.get("acceptedAnswers"), errors);
        }
    }

    private void validateChoice(
            CurriculumContent.QuestionContent question,
            String answerField,
            boolean multiple,
            List<String> errors) {
        String code = question.questionCode();
        JsonNode options = question.options();
        if (options == null || !options.isArray() || options.size() < 2) {
            errors.add(code + " choice question must have at least two options");
            return;
        }
        Set<String> optionIds = new HashSet<>();
        Set<String> optionTexts = new HashSet<>();
        for (JsonNode option : options) {
            String id = option.path("id").asText("").trim();
            String text = normalize(option.path("text").asText(""));
            if (id.isEmpty() || text.isEmpty() || !optionIds.add(id) || !optionTexts.add(text)) {
                errors.add(code + " has empty or duplicate choice options");
            }
        }
        Set<String> expected = multiple
                ? new HashSet<>(stringValues(question.correctAnswer().get(answerField)))
                : Set.of(question.correctAnswer().path(answerField).asText(""));
        if ((!multiple && expected.contains("")) || (multiple && expected.size() < 2)
                || !optionIds.containsAll(expected)) {
            errors.add(code + " correct choice answer does not match its options");
        }
    }

    private void validateTextAnswers(String code, JsonNode values, List<String> errors) {
        List<String> answers = stringValues(values);
        if (answers.isEmpty() || answers.stream().anyMatch(String::isBlank)) {
            errors.add(code + " requires at least one non-empty accepted answer");
        }
    }

    private List<String> stringValues(JsonNode node) {
        if (node == null || !node.isArray()) {
            return List.of();
        }
        return StreamSupport.stream(node.spliterator(), false)
                .filter(JsonNode::isTextual)
                .map(JsonNode::textValue)
                .toList();
    }

    private Map<String, Long> frequency(List<String> values) {
        return values.stream().collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
    }

    private String signature(CurriculumContent.QuestionContent question, boolean normalize) {
        String raw = question.questionContent() + "|" + question.options() + "|" + question.correctAnswer();
        return normalize ? normalize(raw) : raw;
    }

    private String signatureByCode(CurriculumContent content, String code) {
        return content.chapters().stream()
                .flatMap(chapter -> chapter.grammarPoints().stream())
                .flatMap(point -> point.lessons().stream())
                .flatMap(lesson -> lesson.questions().stream())
                .filter(question -> code.equals(question.questionCode()))
                .findFirst()
                .map(question -> signature(question, true))
                .orElse("");
    }

    private String normalize(String value) {
        return Normalizer.normalize(value, Normalizer.Form.NFKC)
                .toLowerCase(Locale.ROOT)
                .replace('“', '"')
                .replace('”', '"')
                .replaceAll("\\s+", " ")
                .replaceAll("\\s*\\|\\s*", "|")
                .trim();
    }

    public record QualityReport(
            int questionCount,
            List<String> errors,
            List<String> warnings,
            int exactDuplicateCount,
            int normalizedDuplicateCount,
            int mechanicalNameVariantCount,
            int explanationMissingCount,
            int aiDraftCount,
            int reviewRequiredCount,
            int approvedCount,
            int microLessonCount,
            int quickCheckCount,
            int readyLessonCount,
            int comingSoonLessonCount
    ) {
        public int validatorErrorCount() {
            return errors.size();
        }

        public int validatorWarningCount() {
            return warnings.size();
        }
    }
}
