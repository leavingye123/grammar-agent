package com.grammaragent.course.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record LearningPathGrammarPointResponse(
        Long id,
        String code,
        String title,
        Integer difficulty,
        Integer sortOrder,
        List<String> prerequisiteCodes,
        List<LearningPathLessonResponse> lessons,
        Integer masteryScore,
        Integer completedLessons,
        Integer totalLessons,
        String status
) {
}
