package com.grammaragent.learning.repository;

import com.grammaragent.learning.entity.LessonAttempt;
import com.grammaragent.learning.mapper.LessonAttemptMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisLessonAttemptRepository implements LessonAttemptRepository {

    private final LessonAttemptMapper mapper;

    @Override
    public Optional<LessonAttempt> findByUserAndId(Long userId, Long attemptId) {
        return Optional.ofNullable(mapper.selectOne(
                com.baomidou.mybatisplus.core.toolkit.Wrappers.<LessonAttempt>lambdaQuery()
                        .eq(LessonAttempt::getUserId, userId)
                        .eq(LessonAttempt::getId, attemptId)));
    }

    @Override
    public LessonAttempt findOrCreateActive(Long userId, Long lessonId, OffsetDateTime now) {
        mapper.insertActiveIfAbsent(userId, lessonId, now);
        LessonAttempt attempt = mapper.selectActive(userId, lessonId);
        if (attempt == null) {
            throw new IllegalStateException(
                    "Active lesson attempt could not be created or found for user " + userId
                            + " and lesson " + lessonId);
        }
        return attempt;
    }

    @Override
    public Optional<LessonAttempt> findActiveForUpdate(Long userId, Long lessonId) {
        return Optional.ofNullable(mapper.selectActiveForUpdate(userId, lessonId));
    }

    @Override
    public void complete(
            Long attemptId,
            int totalCount,
            int correctCount,
            int score,
            int xpEarned,
            OffsetDateTime completedAt) {
        mapper.complete(
                attemptId,
                completedAt,
                totalCount,
                correctCount,
                score,
                xpEarned,
                completedAt);
    }

    @Override
    public List<LessonAttempt> findByUserAndLesson(Long userId, Long lessonId) {
        return mapper.selectByUserAndLesson(userId, lessonId);
    }

    @Override
    public long countCompletedAfter(Long userId, OffsetDateTime since) {
        return mapper.countCompletedAfter(userId, since);
    }

    @Override
    public long sumXpCompletedAfter(Long userId, OffsetDateTime since) {
        return mapper.sumXpCompletedAfter(userId, since);
    }

    @Override
    public long sumTotalCompletedXp(Long userId) {
        return mapper.sumTotalCompletedXp(userId);
    }
}
