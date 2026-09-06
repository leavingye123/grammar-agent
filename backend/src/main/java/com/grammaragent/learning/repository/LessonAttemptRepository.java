package com.grammaragent.learning.repository;

import com.grammaragent.learning.entity.LessonAttempt;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

public interface LessonAttemptRepository {

    LessonAttempt findOrCreateActive(Long userId, Long lessonId, OffsetDateTime now);

    Optional<LessonAttempt> findActiveForUpdate(Long userId, Long lessonId);

    void complete(
            Long attemptId,
            int totalCount,
            int correctCount,
            int score,
            int xpEarned,
            OffsetDateTime completedAt);

    List<LessonAttempt> findByUserAndLesson(Long userId, Long lessonId);

    long countCompletedAfter(Long userId, OffsetDateTime since);

    long sumXpCompletedAfter(Long userId, OffsetDateTime since);

    long sumTotalCompletedXp(Long userId);
}
