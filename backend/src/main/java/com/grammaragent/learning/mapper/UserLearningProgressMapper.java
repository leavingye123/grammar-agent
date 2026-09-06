package com.grammaragent.learning.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.learning.entity.UserLearningProgress;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.OffsetDateTime;

@Mapper
public interface UserLearningProgressMapper extends BaseMapper<UserLearningProgress> {

    @Insert("""
            INSERT INTO user_learning_progress (
                user_id, grammar_point_id, mastery_score, total_questions,
                correct_questions, last_study_at, created_at, updated_at
            ) VALUES (
                #{userId}, #{grammarPointId}, 0, 0, 0,
                #{studiedAt}, #{studiedAt}, #{studiedAt}
            )
            ON CONFLICT (user_id, grammar_point_id) DO NOTHING
            """)
    int insertIfAbsent(
            @Param("userId") Long userId,
            @Param("grammarPointId") Long grammarPointId,
            @Param("studiedAt") OffsetDateTime studiedAt);

    @Select("""
            SELECT *
            FROM user_learning_progress
            WHERE user_id = #{userId} AND grammar_point_id = #{grammarPointId}
            FOR UPDATE
            """)
    UserLearningProgress selectForUpdate(
            @Param("userId") Long userId,
            @Param("grammarPointId") Long grammarPointId);
}
