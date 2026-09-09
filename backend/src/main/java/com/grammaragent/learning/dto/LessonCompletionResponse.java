package com.grammaragent.learning.dto;

import com.grammaragent.learning.enums.LessonProgressStatus;

public record LessonCompletionResponse(
        Long lessonId,
        LessonProgressStatus status,
        int totalCount,
        int correctCount,
        int score,
        int xpEarned,
        Long lessonAttemptId
) {
}
