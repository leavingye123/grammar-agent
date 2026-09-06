package com.grammaragent.question.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.question.entity.WrongQuestion;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.OffsetDateTime;
import java.util.List;

@Mapper
public interface WrongQuestionMapper extends BaseMapper<WrongQuestion> {

    @Insert("""
            INSERT INTO wrong_questions (
                user_id, question_id, wrong_count, last_wrong_at,
                next_review_at, mastered, created_at, updated_at
            ) VALUES (
                #{userId}, #{questionId}, 1, #{wrongAt},
                #{nextReviewAt}, FALSE, #{wrongAt}, #{wrongAt}
            )
            ON CONFLICT (user_id, question_id) DO UPDATE SET
                wrong_count = wrong_questions.wrong_count + 1,
                last_wrong_at = EXCLUDED.last_wrong_at,
                next_review_at = EXCLUDED.next_review_at,
                mastered = FALSE,
                updated_at = EXCLUDED.updated_at
            """)
    int upsertWrong(
            @Param("userId") Long userId,
            @Param("questionId") Long questionId,
            @Param("wrongAt") OffsetDateTime wrongAt,
            @Param("nextReviewAt") OffsetDateTime nextReviewAt);

    @Select("""
            SELECT w.*
            FROM wrong_questions w
            JOIN questions q ON q.id = w.question_id AND q.enabled = TRUE
            WHERE w.user_id = #{userId}
              AND w.mastered = FALSE
              AND w.next_review_at <= #{now}
            ORDER BY w.next_review_at ASC, w.wrong_count DESC, w.id ASC
            LIMIT #{limit}
            """)
    List<WrongQuestion> selectDueByUserId(
            @Param("userId") Long userId,
            @Param("now") OffsetDateTime now,
            @Param("limit") int limit);

    @Select("""
            SELECT w.*
            FROM wrong_questions w
            JOIN questions q ON q.id = w.question_id AND q.enabled = TRUE
            WHERE w.user_id = #{userId}
              AND w.mastered = FALSE
            ORDER BY w.wrong_count DESC, w.next_review_at ASC NULLS LAST, w.id ASC
            LIMIT #{limit} OFFSET #{offset}
            """)
    List<WrongQuestion> selectUnmasteredByUserId(
            @Param("userId") Long userId,
            @Param("offset") int offset,
            @Param("limit") int limit);

    @Select("""
            SELECT
                COUNT(*) FILTER (
                    WHERE w.mastered = FALSE AND w.next_review_at <= #{now}
                ) AS due_count,
                COUNT(*) FILTER (WHERE w.mastered = FALSE) AS unmastered_count,
                COUNT(*) FILTER (WHERE w.mastered = TRUE) AS mastered_count,
                MIN(w.next_review_at) FILTER (WHERE w.mastered = FALSE) AS next_review_at
            FROM wrong_questions w
            JOIN questions q ON q.id = w.question_id AND q.enabled = TRUE
            WHERE w.user_id = #{userId}
            """)
    com.grammaragent.question.repository.WrongQuestionSummary selectSummary(
            @Param("userId") Long userId,
            @Param("now") OffsetDateTime now);

    @Select("""
            SELECT *
            FROM wrong_questions
            WHERE user_id = #{userId} AND question_id = #{questionId}
            FOR UPDATE
            """)
    WrongQuestion selectForUpdate(
            @Param("userId") Long userId,
            @Param("questionId") Long questionId);

    @Update("""
            UPDATE wrong_questions
            SET wrong_count = #{wrongQuestion.wrongCount},
                last_wrong_at = #{wrongQuestion.lastWrongAt},
                next_review_at = #{wrongQuestion.nextReviewAt},
                mastered = #{wrongQuestion.mastered},
                updated_at = #{updatedAt}
            WHERE id = #{wrongQuestion.id}
            """)
    int updateReviewResult(
            @Param("wrongQuestion") WrongQuestion wrongQuestion,
            @Param("updatedAt") OffsetDateTime updatedAt);
}
