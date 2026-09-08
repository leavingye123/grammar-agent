package com.grammaragent.content;

import com.grammaragent.content.model.CurriculumContent;
import com.grammaragent.content.model.CurriculumContent.GrammarPointContent;
import com.grammaragent.question.enums.QuestionType;
import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

@Component
public class CurriculumContentValidator {

    private static final Pattern A1_CODE = Pattern.compile("A1-\\d{3}");
    private static final Pattern PLACEHOLDER_LESSON = Pattern.compile("(?i)^lesson\\s*\\d+$");
    private final QuestionContentValidator questionContentValidator = new QuestionContentValidator();

    public CurriculumStats validate(CurriculumContent content) {
        List<String> errors = new ArrayList<>();
        if (!"en".equals(content.languageCode()) || !"A1".equals(content.levelCode())) {
            errors.add("Only the English A1 curriculum may be imported in Stage 8A");
        }
        if (content.chapters() == null || content.chapters().size() < 5 || content.chapters().size() > 8) {
            errors.add("English A1 must contain 5 to 8 chapters");
        }

        List<GrammarPointContent> points = content.chapters() == null
                ? List.of()
                : content.chapters().stream().flatMap(chapter -> chapter.grammarPoints().stream()).toList();
        Map<String, GrammarPointContent> byCode = new HashMap<>();
        Set<Integer> pointSortOrders = new HashSet<>();
        Set<QuestionType> questionTypes = EnumSet.noneOf(QuestionType.class);
        int lessonCount = 0;
        int questionCount = 0;
        int prerequisiteCount = 0;

        for (GrammarPointContent point : points) {
            if (!A1_CODE.matcher(point.code()).matches()) {
                errors.add("Invalid grammar point code: " + point.code());
            }
            if (byCode.put(point.code(), point) != null) {
                errors.add("Duplicate grammar point code: " + point.code());
            }
            if (!pointSortOrders.add(point.sortOrder())) {
                errors.add("Duplicate grammar point sort order: " + point.sortOrder());
            }
            if (point.lessons() == null || point.lessons().size() < 2 || point.lessons().size() > 5) {
                errors.add(point.code() + " must contain 2 to 5 lessons");
                continue;
            }
            Set<Integer> lessonSortOrders = new HashSet<>();
            for (var lesson : point.lessons()) {
                lessonCount++;
                if (!lessonSortOrders.add(lesson.sortOrder())) {
                    errors.add(point.code() + " has a duplicate lesson sort order");
                }
                if (lesson.title() == null || lesson.title().isBlank()
                        || PLACEHOLDER_LESSON.matcher(lesson.title()).matches()) {
                    errors.add(point.code() + " has a placeholder lesson title");
                }
                Set<Integer> questionSortOrders = new HashSet<>();
                for (var question : lesson.questions()) {
                    questionCount++;
                    questionTypes.add(question.questionType());
                    if (!questionSortOrders.add(question.sortOrder())) {
                        errors.add(point.code() + " has a duplicate question sort order");
                    }
                }
            }
            Set<String> localPrerequisites = new HashSet<>();
            for (String prerequisite : point.prerequisiteCodes()) {
                prerequisiteCount++;
                if (point.code().equals(prerequisite)) {
                    errors.add(point.code() + " depends on itself");
                }
                if (!localPrerequisites.add(prerequisite)) {
                    errors.add(point.code() + " repeats prerequisite " + prerequisite);
                }
            }
        }

        if (points.size() != 45) {
            errors.add("Expected exactly 45 A1 grammar points but found " + points.size());
        }
        for (int index = 1; index <= 45; index++) {
            String expected = "A1-%03d".formatted(index);
            if (!byCode.containsKey(expected)) {
                errors.add("Missing grammar point " + expected);
            }
        }
        for (GrammarPointContent point : points) {
            for (String prerequisite : point.prerequisiteCodes()) {
                if (!byCode.containsKey(prerequisite)) {
                    errors.add(point.code() + " has unknown prerequisite " + prerequisite);
                }
            }
        }
        detectCycles(byCode, errors);
        if (lessonCount < 120 || lessonCount > 160) {
            errors.add("Expected 120 to 160 lessons but found " + lessonCount);
        }
        if (questionCount < 40) {
            errors.add("Expected at least 40 authored questions but found " + questionCount);
        }
        if (!questionTypes.equals(EnumSet.allOf(QuestionType.class))) {
            errors.add("All six question types must be represented");
        }
        var qualityReport = questionContentValidator.inspect(content);
        errors.addAll(qualityReport.errors());
        if (!errors.isEmpty()) {
            throw new IllegalStateException("Invalid curriculum content:\n- " + String.join("\n- ", errors));
        }
        return new CurriculumStats(points.size(), lessonCount, questionCount, prerequisiteCount, questionTypes);
    }

    private void detectCycles(Map<String, GrammarPointContent> points, List<String> errors) {
        Set<String> visited = new HashSet<>();
        Set<String> active = new HashSet<>();
        ArrayDeque<String> path = new ArrayDeque<>();
        for (String code : points.keySet()) {
            visit(code, points, visited, active, path, errors);
        }
    }

    private void visit(
            String code,
            Map<String, GrammarPointContent> points,
            Set<String> visited,
            Set<String> active,
            ArrayDeque<String> path,
            List<String> errors) {
        if (visited.contains(code)) {
            return;
        }
        if (!active.add(code)) {
            errors.add("Prerequisite cycle detected at " + code + " through " + path);
            return;
        }
        path.addLast(code);
        GrammarPointContent point = points.get(code);
        if (point != null) {
            for (String prerequisite : point.prerequisiteCodes()) {
                visit(prerequisite, points, visited, active, path, errors);
            }
        }
        path.removeLast();
        active.remove(code);
        visited.add(code);
    }

    public record CurriculumStats(
            int grammarPoints,
            int lessons,
            int questions,
            int prerequisites,
            Set<QuestionType> questionTypes
    ) {
    }
}
