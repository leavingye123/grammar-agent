package com.grammaragent.learning.repository;

import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;

import java.time.OffsetDateTime;
import java.util.Optional;

public interface LessonProgressRepository {

    void upsert(
            Long userId,
            Long lessonId,
            LessonProgressStatus status,
            int score,
            int correctCount,
            int totalCount,
            int xpEarned,
            OffsetDateTime now);

    Optional<UserLessonProgress> findByUserAndLesson(Long userId, Long lessonId);
}
