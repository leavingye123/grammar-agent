package com.grammaragent.question.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.question.entity.WrongQuestion;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.OffsetDateTime;

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
}
