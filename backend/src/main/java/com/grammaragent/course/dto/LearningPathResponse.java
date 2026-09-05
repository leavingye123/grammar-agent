package com.grammaragent.course.dto;

import java.util.List;

public record LearningPathResponse(
        LanguageResponse language,
        List<LearningPathLevelResponse> levels
) {
}
