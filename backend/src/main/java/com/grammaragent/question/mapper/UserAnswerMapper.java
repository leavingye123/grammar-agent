package com.grammaragent.question.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.grammaragent.question.entity.UserAnswer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Collection;
import java.util.List;

@Mapper
public interface UserAnswerMapper extends BaseMapper<UserAnswer> {

    @Select("""
            <script>
            SELECT DISTINCT ON (question_id)
                   id, user_id, question_id, is_correct, answered_at, created_at, updated_at
            FROM user_answers
            WHERE user_id = #{userId}
              AND lesson_attempt_id = #{attemptId}
              AND question_id IN
              <foreach collection="questionIds" item="questionId" open="(" separator="," close=")">
                  #{questionId}
              </foreach>
            ORDER BY question_id, answered_at DESC, id DESC
            </script>
            """)
    List<UserAnswer> selectLatestByQuestionIdsInAttempt(
            @Param("userId") Long userId,
            @Param("questionIds") Collection<Long> questionIds,
            @Param("attemptId") Long attemptId);

    @Select("""
            SELECT
                COUNT(*) AS total,
                COUNT(*) FILTER (WHERE is_correct) AS correct
            FROM user_answers
            WHERE user_id = #{userId}
            """)
    com.grammaragent.question.repository.UserAnswerCounts selectCounts(
            @Param("userId") Long userId);
}
