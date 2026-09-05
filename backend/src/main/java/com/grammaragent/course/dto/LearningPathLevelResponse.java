package com.grammaragent.course.dto;

import java.util.List;

public record LearningPathLevelResponse(
        Long id,
        String code,
        String name,
        Integer sortOrder,
        List<LearningPathChapterResponse> chapters
) {
}
