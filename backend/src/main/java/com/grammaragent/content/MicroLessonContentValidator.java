package com.grammaragent.content;

import com.grammaragent.content.model.CurriculumContent;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

@Component
public class MicroLessonContentValidator {

    private static final Pattern CHECK_CODE = Pattern.compile("A1-\\d{3}-MQ\\d{2}");

    public ValidationResult validate(CurriculumContent content) {
        List<String> errors = new ArrayList<>();
        Set<String> checkCodes = new HashSet<>();
        int microLessonCount = 0;
        int quickCheckCount = 0;

        for (var chapter : content.chapters()) {
            for (var point : chapter.grammarPoints()) {
                var micro = point.microLesson();
                if (micro == null) {
                    continue;
                }
                microLessonCount++;
                requireText(point.code(), "learningObjective", micro.learningObjective(), errors);
                requireText(point.code(), "shortIntroduction", micro.shortIntroduction(), errors);
                requireText(point.code(), "coreRule", micro.coreRule(), errors);
                requireNonBlank(point.code(), "structure", micro.structure(), errors);
                if (micro.examples() == null || !micro.examples().isArray() || micro.examples().isEmpty()) {
                    errors.add(point.code() + " micro lesson requires examples");
                } else {
                    for (var example : micro.examples()) {
                        requireNonBlank(point.code(), "example.sentence", example.path("sentence").asText(), errors);
                        requireNonBlank(point.code(), "example.note", example.path("note").asText(), errors);
                    }
                }
                if (micro.commonMistakes() == null || !micro.commonMistakes().isArray()
                        || micro.commonMistakes().isEmpty()) {
                    errors.add(point.code() + " micro lesson requires common mistakes");
                } else {
                    for (var mistake : micro.commonMistakes()) {
                        String incorrect = mistake.path("incorrect").asText();
                        String correct = mistake.path("correct").asText();
                        requireNonBlank(point.code(), "commonMistake.incorrect", incorrect, errors);
                        requireNonBlank(point.code(), "commonMistake.correct", correct, errors);
                        requireText(point.code(), "commonMistake.reason", mistake.path("reason").asText(), errors);
                        if (!incorrect.isBlank() && incorrect.equalsIgnoreCase(correct)) {
                            errors.add(point.code() + " common mistake does not change the example");
                        }
                    }
                }
                if (micro.quickCheck() == null || micro.quickCheck().isEmpty() || micro.quickCheck().size() > 2) {
                    errors.add(point.code() + " micro lesson requires one or two quick checks");
                    continue;
                }
                for (var check : micro.quickCheck()) {
                    quickCheckCount++;
                    if (check.checkCode() == null || !CHECK_CODE.matcher(check.checkCode()).matches()
                            || !check.checkCode().startsWith(point.code() + "-MQ")
                            || !checkCodes.add(check.checkCode())) {
                        errors.add(point.code() + " has an invalid or duplicate quick-check code");
                    }
                    requireText(point.code(), "quickCheck.prompt", check.prompt(), errors);
                    requireText(point.code(), "quickCheck.explanation", check.explanation(), errors);
                    if (check.options() == null || !check.options().isArray() || check.options().size() < 2) {
                        errors.add(check.checkCode() + " requires at least two options");
                    } else {
                        boolean answerExists = false;
                        Set<String> ids = new HashSet<>();
                        Set<String> texts = new HashSet<>();
                        for (var option : check.options()) {
                            String id = option.path("id").asText("");
                            String text = option.path("text").asText("").trim().toLowerCase(Locale.ROOT);
                            if (id.isBlank() || text.isBlank() || !ids.add(id) || !texts.add(text)) {
                                errors.add(check.checkCode() + " has invalid options");
                            }
                            answerExists |= id.equals(check.correctOptionId());
                        }
                        if (!answerExists) {
                            errors.add(check.checkCode() + " answer is not present in options");
                        }
                    }
                }
            }
        }
        if (!errors.isEmpty()) {
            throw new IllegalStateException("Invalid micro lesson content:\n- " + String.join("\n- ", errors));
        }
        return new ValidationResult(microLessonCount, quickCheckCount);
    }

    private void requireText(String code, String field, String value, List<String> errors) {
        if (value == null || value.trim().length() < 8) {
            errors.add(code + " micro lesson has empty " + field);
        }
    }

    private void requireNonBlank(String code, String field, String value, List<String> errors) {
        if (value == null || value.isBlank()) {
            errors.add(code + " micro lesson has empty " + field);
        }
    }

    public record ValidationResult(int microLessonCount, int quickCheckCount) {
    }
}
