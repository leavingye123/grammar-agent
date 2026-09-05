package com.grammaragent.course.dto;

import java.util.List;

public record LearningPathChapterResponse(
        Long id,
        String title,
        Integer sortOrder,
        List<LearningPathGrammarPointResponse> grammarPoints
) {
}
