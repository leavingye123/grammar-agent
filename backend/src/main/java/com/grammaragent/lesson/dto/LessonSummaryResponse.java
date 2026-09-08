package com.grammaragent.lesson.dto;

import com.grammaragent.lesson.enums.LessonType;
import com.grammaragent.lesson.enums.LessonContentStatus;

public record LessonSummaryResponse(
        Long id,
        String title,
        String description,
        LessonType lessonType,
        Integer xpReward,
        Integer sortOrder,
        Integer questionCount,
        LessonContentStatus contentStatus
) {
}
