package com.grammaragent.course.dto;

import com.grammaragent.lesson.enums.LessonType;

public record LearningPathLessonResponse(
        Long id,
        String title,
        LessonType lessonType,
        Integer xpReward,
        Integer sortOrder
) {
}
