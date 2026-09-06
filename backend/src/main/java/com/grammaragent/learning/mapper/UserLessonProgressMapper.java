package com.grammaragent.learning.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.learning.entity.UserLessonProgress;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.OffsetDateTime;

@Mapper
public interface UserLessonProgressMapper extends BaseMapper<UserLessonProgress> {

    @Insert("""
            INSERT INTO user_lesson_progress (
                user_id, lesson_id, status, score, correct_count, total_count,
                xp_earned, started_at, completed_at, created_at, updated_at
            ) VALUES (
                #{userId}, #{lessonId}, #{status}, #{score}, #{correctCount}, #{totalCount},
                #{xpEarned}, #{now}, #{completedAt}, #{now}, #{now}
            )
            ON CONFLICT (user_id, lesson_id) DO UPDATE SET
                status = EXCLUDED.status,
                score = EXCLUDED.score,
                correct_count = EXCLUDED.correct_count,
                total_count = EXCLUDED.total_count,
                xp_earned = EXCLUDED.xp_earned,
                completed_at = EXCLUDED.completed_at,
                updated_at = EXCLUDED.updated_at
            """)
    int upsertProgress(
            @Param("userId") Long userId,
            @Param("lessonId") Long lessonId,
            @Param("status") String status,
            @Param("score") int score,
            @Param("correctCount") int correctCount,
            @Param("totalCount") int totalCount,
            @Param("xpEarned") int xpEarned,
            @Param("now") OffsetDateTime now,
            @Param("completedAt") OffsetDateTime completedAt);
}
