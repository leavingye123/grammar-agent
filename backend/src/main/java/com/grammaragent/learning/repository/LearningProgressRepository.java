package com.grammaragent.learning.repository;

import com.grammaragent.learning.entity.UserLearningProgress;

import java.time.OffsetDateTime;

public interface LearningProgressRepository {

    UserLearningProgress incrementAndGet(
            Long userId,
            Long grammarPointId,
            boolean correct,
            OffsetDateTime studiedAt);
}
