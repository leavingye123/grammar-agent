package com.grammaragent.content.model;

import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.lesson.enums.LessonType;
import com.grammaragent.question.enums.QuestionType;

import java.util.List;

public record CurriculumContent(
        String version,
        String languageCode,
        String languageName,
        String nativeName,
        String levelCode,
        String levelName,
        String levelDescription,
        List<ChapterContent> chapters
) {

    public record ChapterContent(
            String key,
            String title,
            String description,
            int sortOrder,
            List<GrammarPointContent> grammarPoints
    ) {
    }

    public record GrammarPointContent(
            String code,
            String title,
            String description,
            String grammarRule,
            JsonNode examples,
            JsonNode commonErrors,
            int difficulty,
            int sortOrder,
            List<String> prerequisiteCodes,
            List<LessonContent> lessons
    ) {
    }

    public record LessonContent(
            String title,
            String description,
            LessonType lessonType,
            int xpReward,
            int sortOrder,
            List<QuestionContent> questions
    ) {
    }

    public record QuestionContent(
            QuestionType questionType,
            String questionContent,
            JsonNode options,
            JsonNode correctAnswer,
            String explanation,
            int difficulty,
            int sortOrder
    ) {
    }
}
