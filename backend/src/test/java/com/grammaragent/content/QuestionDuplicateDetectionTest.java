package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.content.model.CurriculumContent;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class QuestionDuplicateDetectionTest {

    @Test
    void exactAndNormalizedDuplicatesAreRejected() {
        var content = new CurriculumContentLoader(new ObjectMapper()).loadEnglishA1();
        var chapter = content.chapters().getFirst();
        var point = chapter.grammarPoints().getFirst();
        var lesson = point.lessons().getFirst();
        var source = lesson.questions().getFirst();
        var duplicate = new CurriculumContent.QuestionContent(
                point.code() + "-Q999",
                source.questionType(),
                "  " + source.questionContent().toUpperCase() + "  ",
                source.options(),
                source.correctAnswer(),
                source.explanation(),
                source.difficulty(),
                99,
                source.provenance(),
                source.reviewStatus());
        var changedLesson = new CurriculumContent.LessonContent(
                lesson.title(), lesson.description(), lesson.lessonType(), lesson.xpReward(), lesson.sortOrder(),
                Stream.concat(lesson.questions().stream(), Stream.of(duplicate)).toList());
        var changedPoint = new CurriculumContent.GrammarPointContent(
                point.code(), point.title(), point.description(), point.grammarRule(), point.examples(),
                point.commonErrors(), point.difficulty(), point.sortOrder(), point.prerequisiteCodes(),
                Stream.concat(Stream.of(changedLesson), point.lessons().stream().skip(1)).toList(), point.microLesson());
        var changedChapter = new CurriculumContent.ChapterContent(
                chapter.key(), chapter.title(), chapter.description(), chapter.sortOrder(),
                Stream.concat(Stream.of(changedPoint), chapter.grammarPoints().stream().skip(1)).toList());
        var changed = new CurriculumContent(
                content.version(), content.languageCode(), content.languageName(), content.nativeName(),
                content.levelCode(), content.levelName(), content.levelDescription(),
                Stream.concat(Stream.of(changedChapter), content.chapters().stream().skip(1)).toList());

        var report = new QuestionContentValidator().inspect(changed);
        assertEquals(1, report.normalizedDuplicateCount());
        assertFalse(report.errors().isEmpty());
    }
}

