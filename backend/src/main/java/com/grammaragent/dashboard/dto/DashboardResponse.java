package com.grammaragent.dashboard.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DashboardResponse(
        User user,
        ContinueLearning continueLearning,
        Today today,
        Review review,
        Progress progress,
        Statistics statistics,
        Streak streak
) {

    public record User(
            String username,
            String currentLanguage,
            String currentLevel
    ) {
    }

    public record ContinueLearning(
            Long grammarPointId,
            String grammarPointTitle,
            Long lessonId,
            String lessonTitle
    ) {
    }

    public record Today(
            int completedLessons,
            int xpEarned,
            int goalXp
    ) {
    }

    public record Review(
            long dueCount
    ) {
    }

    public record Progress(
            int completedLessons,
            int totalLessons,
            int averageMastery
    ) {
    }

    public record Statistics(
            long totalAnsweredQuestions,
            long correctAnswers,
            int accuracy,
            long totalXp
    ) {
    }

    public record Streak(
            int currentStreak,
            int maxStreak
    ) {
    }
}
