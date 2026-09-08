package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.content.model.CurriculumContent;
import org.junit.jupiter.api.Test;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MicroLessonContentValidatorTest {

    @Test
    void curatedSampleHasCompleteKnowledgeAndIndependentQuickChecks() {
        var content = new CurriculumContentLoader(new ObjectMapper()).loadEnglishA1();
        var result = new MicroLessonContentValidator().validate(content);
        Set<String> covered = content.chapters().stream()
                .flatMap(chapter -> chapter.grammarPoints().stream())
                .filter(point -> point.microLesson() != null)
                .map(point -> point.code())
                .collect(Collectors.toSet());

        assertEquals(13, result.microLessonCount());
        assertEquals(26, result.quickCheckCount());
        assertTrue(covered.containsAll(Set.of(
                "A1-001", "A1-002", "A1-003", "A1-004", "A1-005", "A1-006", "A1-007", "A1-008",
                "A1-009", "A1-012", "A1-016", "A1-019", "A1-020")));
    }

    @Test
    void shortNonBlankStructureExamplesAreValid() {
        var source = new CurriculumContentLoader(new ObjectMapper()).loadEnglishA1();
        var chapter = source.chapters().getFirst();
        var point = chapter.grammarPoints().getFirst();
        var micro = point.microLesson();
        var shortStructure = new CurriculumContent.MicroLessonContent(
                micro.learningObjective(), micro.shortIntroduction(), micro.coreRule(), "a book",
                micro.examples(), micro.commonMistakes(), micro.memoryTip(), micro.quickCheck());
        var changedPoint = new CurriculumContent.GrammarPointContent(
                point.code(), point.title(), point.description(), point.grammarRule(), point.examples(),
                point.commonErrors(), point.difficulty(), point.sortOrder(), point.prerequisiteCodes(),
                point.lessons(), shortStructure);
        var changedChapter = new CurriculumContent.ChapterContent(
                chapter.key(), chapter.title(), chapter.description(), chapter.sortOrder(),
                Stream.concat(Stream.of(changedPoint), chapter.grammarPoints().stream().skip(1)).toList());
        var changed = new CurriculumContent(
                source.version(), source.languageCode(), source.languageName(), source.nativeName(),
                source.levelCode(), source.levelName(), source.levelDescription(),
                Stream.concat(Stream.of(changedChapter), source.chapters().stream().skip(1)).toList());

        var result = new MicroLessonContentValidator().validate(changed);

        assertEquals(13, result.microLessonCount());
        assertEquals(26, result.quickCheckCount());
    }
}
