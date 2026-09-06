package com.grammaragent.learning.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.learning.entity.UserLessonProgress;
import com.grammaragent.learning.enums.LessonProgressStatus;
import com.grammaragent.learning.mapper.UserLessonProgressMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisLessonProgressRepository implements LessonProgressRepository {

    private final UserLessonProgressMapper mapper;

    @Override
    public void upsert(
            Long userId,
            Long lessonId,
            LessonProgressStatus status,
            int score,
            int correctCount,
            int totalCount,
            int xpEarned,
            OffsetDateTime now) {
        OffsetDateTime completedAt = status == LessonProgressStatus.COMPLETED ? now : null;
        mapper.upsertProgress(
                userId,
                lessonId,
                status.getValue(),
                score,
                correctCount,
                totalCount,
                xpEarned,
                now,
                completedAt);
    }

    @Override
    public Optional<UserLessonProgress> findByUserAndLesson(Long userId, Long lessonId) {
        return Optional.ofNullable(mapper.selectOne(Wrappers.<UserLessonProgress>lambdaQuery()
                .eq(UserLessonProgress::getUserId, userId)
                .eq(UserLessonProgress::getLessonId, lessonId)));
    }
}
