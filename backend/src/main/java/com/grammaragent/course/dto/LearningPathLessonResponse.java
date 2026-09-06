package com.grammaragent.course.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.grammaragent.lesson.enums.LessonType;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record LearningPathLessonResponse(
        Long id,
        String title,
        LessonType lessonType,
        Integer xpReward,
        Integer sortOrder,
        String status
) {
}
