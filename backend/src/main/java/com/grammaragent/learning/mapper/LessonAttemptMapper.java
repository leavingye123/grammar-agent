package com.grammaragent.learning.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.learning.entity.LessonAttempt;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.OffsetDateTime;
import java.util.List;

@Mapper
public interface LessonAttemptMapper extends BaseMapper<LessonAttempt> {

    @Insert("""
            INSERT INTO lesson_attempts (
                user_id, lesson_id, status, started_at, created_at, updated_at
            ) VALUES (
                #{userId}, #{lessonId}, 'IN_PROGRESS', #{now}, #{now}, #{now}
            )
            ON CONFLICT (user_id, lesson_id) WHERE status = 'IN_PROGRESS' DO NOTHING
            """)
    int insertActiveIfAbsent(
            @Param("userId") Long userId,
            @Param("lessonId") Long lessonId,
            @Param("now") OffsetDateTime now);

    @Select("""
            SELECT *
            FROM lesson_attempts
            WHERE user_id = #{userId}
              AND lesson_id = #{lessonId}
              AND status = 'IN_PROGRESS'
            ORDER BY started_at DESC, id DESC
            LIMIT 1
            """)
    LessonAttempt selectActive(
            @Param("userId") Long userId,
            @Param("lessonId") Long lessonId);

    @Select("""
            SELECT *
            FROM lesson_attempts
            WHERE user_id = #{userId}
              AND lesson_id = #{lessonId}
              AND status = 'IN_PROGRESS'
            ORDER BY started_at DESC, id DESC
            LIMIT 1
            FOR UPDATE
            """)
    LessonAttempt selectActiveForUpdate(
            @Param("userId") Long userId,
            @Param("lessonId") Long lessonId);

    @Update("""
            UPDATE lesson_attempts
            SET status = 'COMPLETED',
                completed_at = #{completedAt},
                total_count = #{totalCount},
                correct_count = #{correctCount},
                score = #{score},
                xp_earned = #{xpEarned},
                updated_at = #{updatedAt}
            WHERE id = #{attemptId}
              AND status = 'IN_PROGRESS'
            """)
    int complete(
            @Param("attemptId") Long attemptId,
            @Param("completedAt") OffsetDateTime completedAt,
            @Param("totalCount") int totalCount,
            @Param("correctCount") int correctCount,
            @Param("score") int score,
            @Param("xpEarned") int xpEarned,
            @Param("updatedAt") OffsetDateTime updatedAt);

    @Select("""
            SELECT *
            FROM lesson_attempts
            WHERE user_id = #{userId}
              AND lesson_id = #{lessonId}
            ORDER BY started_at DESC, id DESC
            """)
    List<LessonAttempt> selectByUserAndLesson(
            @Param("userId") Long userId,
            @Param("lessonId") Long lessonId);

    @Select("""
            SELECT COUNT(*)
            FROM lesson_attempts
            WHERE user_id = #{userId}
              AND status = 'COMPLETED'
              AND completed_at >= #{since}
            """)
    long countCompletedAfter(
            @Param("userId") Long userId,
            @Param("since") OffsetDateTime since);

    @Select("""
            SELECT COALESCE(SUM(xp_earned), 0)
            FROM lesson_attempts
            WHERE user_id = #{userId}
              AND status = 'COMPLETED'
              AND completed_at >= #{since}
            """)
    long sumXpCompletedAfter(
            @Param("userId") Long userId,
            @Param("since") OffsetDateTime since);

    @Select("""
            SELECT COALESCE(SUM(xp_earned), 0)
            FROM lesson_attempts
            WHERE user_id = #{userId}
              AND status = 'COMPLETED'
            """)
    long sumTotalCompletedXp(@Param("userId") Long userId);
}
