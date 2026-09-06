package com.grammaragent.learning.dto;

import com.grammaragent.learning.enums.LessonAttemptStatus;

import java.time.OffsetDateTime;

public record LessonAttemptResponse(
        Long id,
        Long lessonId,
        LessonAttemptStatus status,
        OffsetDateTime startedAt,
        OffsetDateTime completedAt,
        int totalCount,
        int correctCount,
        int score,
        int xpEarned
) {
}
