package com.grammaragent.lesson.dto;

import com.grammaragent.lesson.enums.LessonType;

public record LessonDetailResponse(
        Long id,
        Long grammarPointId,
        String title,
        String description,
        LessonType lessonType,
        Integer xpReward,
        Integer sortOrder
) {
}
