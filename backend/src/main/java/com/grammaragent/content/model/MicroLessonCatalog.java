package com.grammaragent.content.model;

import com.fasterxml.jackson.databind.JsonNode;

import java.util.List;

public record MicroLessonCatalog(
        String version,
        List<MicroLessonEntry> microLessons
) {
    public record MicroLessonEntry(
            String grammarPointCode,
            String learningObjective,
            String shortIntroduction,
            String coreRule,
            String structure,
            JsonNode examples,
            JsonNode commonMistakes,
            String memoryTip,
            List<CurriculumContent.QuickCheckContent> quickCheck
    ) {
        public CurriculumContent.MicroLessonContent toContent() {
            return new CurriculumContent.MicroLessonContent(
                    learningObjective,
                    shortIntroduction,
                    coreRule,
                    structure,
                    examples,
                    commonMistakes,
                    memoryTip,
                    quickCheck);
        }
    }
}

