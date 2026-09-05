package com.grammaragent.course.dto;

import java.util.List;

public record LearningPathGrammarPointResponse(
        Long id,
        String code,
        String title,
        Integer difficulty,
        Integer sortOrder,
        List<LearningPathLessonResponse> lessons
) {
}
