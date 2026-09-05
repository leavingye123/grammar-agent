package com.grammaragent.lesson.dto;

import com.grammaragent.lesson.enums.LessonType;

public record LessonSummaryResponse(
        Long id,
        String title,
        String description,
        LessonType lessonType,
        Integer xpReward,
        Integer sortOrder
) {
}
