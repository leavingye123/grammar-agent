package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.question.enums.QuestionType;
import org.junit.jupiter.api.Test;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CurriculumContentIntegrityTest {

    private final CurriculumContentLoader loader = new CurriculumContentLoader(new ObjectMapper());
    private final CurriculumContentValidator validator = new CurriculumContentValidator();

    @Test
    void englishA1SourceContainsExactValidatedCurriculum() {
        var content = loader.loadEnglishA1();
        var stats = validator.validate(content);

        assertEquals("en-a1-v2", content.version());
        assertEquals(7, content.chapters().size());
        assertEquals(45, stats.grammarPoints());
        assertEquals(135, stats.lessons());
        assertEquals(128, stats.questions());
        assertEquals(57, stats.prerequisites());
        assertEquals(QuestionType.values().length, stats.questionTypes().size());

        var points = content.chapters().stream()
                .flatMap(chapter -> chapter.grammarPoints().stream())
                .collect(Collectors.toMap(point -> point.code(), Function.identity()));
        assertEquals("基础句子骨架：Subject + Verb (+ Object/Complement)", points.get("A1-001").title());
        assertEquals("be 动词肯定句：am / is / are", points.get("A1-003").title());
        assertEquals("基础语序整合：Subject + Verb + Object + Place + Time", points.get("A1-045").title());
        assertTrue(points.get("A1-008").prerequisiteCodes().containsAll(java.util.List.of("A1-006", "A1-007")));
        assertFalse(points.containsKey("A2-001"));
    }

    @Test
    void authoredPacksUseAllSixQuestionTypesWithReviewedDistribution() {
        Map<QuestionType, Long> distribution = loader.loadEnglishA1().chapters().stream()
                .flatMap(chapter -> chapter.grammarPoints().stream())
                .flatMap(point -> point.lessons().stream())
                .flatMap(lesson -> lesson.questions().stream())
                .collect(Collectors.groupingBy(
                        question -> question.questionType(),
                        () -> new EnumMap<>(QuestionType.class),
                        Collectors.counting()));

        assertEquals(Map.of(
                QuestionType.SINGLE_CHOICE, 27L,
                QuestionType.MULTIPLE_CHOICE, 19L,
                QuestionType.FILL_BLANK, 23L,
                QuestionType.SENTENCE_ORDER, 20L,
                QuestionType.TRUE_FALSE, 18L,
                QuestionType.CORRECTION, 21L), distribution);
    }

    @Test
    void validatorRejectsPrerequisiteCycles() {
        var source = loader.loadEnglishA1();
        var firstChapter = source.chapters().getFirst();
        var firstPoint = firstChapter.grammarPoints().getFirst();
        var cyclicFirstPoint = new com.grammaragent.content.model.CurriculumContent.GrammarPointContent(
                firstPoint.code(), firstPoint.title(), firstPoint.description(), firstPoint.grammarRule(),
                firstPoint.examples(), firstPoint.commonErrors(), firstPoint.difficulty(), firstPoint.sortOrder(),
                List.of("A1-045"), firstPoint.lessons(), firstPoint.microLesson());
        var cyclicFirstChapter = new com.grammaragent.content.model.CurriculumContent.ChapterContent(
                firstChapter.key(), firstChapter.title(), firstChapter.description(), firstChapter.sortOrder(),
                java.util.stream.Stream.concat(
                        java.util.stream.Stream.of(cyclicFirstPoint),
                        firstChapter.grammarPoints().stream().skip(1)).toList());
        var cyclic = new com.grammaragent.content.model.CurriculumContent(
                source.version(), source.languageCode(), source.languageName(), source.nativeName(),
                source.levelCode(), source.levelName(), source.levelDescription(),
                java.util.stream.Stream.concat(
                        java.util.stream.Stream.of(cyclicFirstChapter),
                        source.chapters().stream().skip(1)).toList());

        IllegalStateException exception = assertThrows(
                IllegalStateException.class,
                () -> validator.validate(cyclic));
        assertTrue(exception.getMessage().contains("cycle"));
    }
}
