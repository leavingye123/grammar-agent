package com.grammaragent.question.repository;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.mapper.UserAnswerMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisUserAnswerRepository implements UserAnswerRepository {

    private final UserAnswerMapper userAnswerMapper;

    @Override
    public Optional<UserAnswer> findLatestByUserAndQuestion(Long userId, Long questionId) {
        return Optional.ofNullable(userAnswerMapper.selectOne(
                Wrappers.<UserAnswer>lambdaQuery()
                        .eq(UserAnswer::getUserId, userId)
                        .eq(UserAnswer::getQuestionId, questionId)
                        .orderByDesc(UserAnswer::getAnsweredAt, UserAnswer::getId)
                        .last("LIMIT 1")));
    }

    @Override
    public void insert(UserAnswer userAnswer) {
        userAnswerMapper.insert(userAnswer);
    }

    @Override
    public List<UserAnswer> findLatestByQuestionIdsInAttempt(
            Long userId, Collection<Long> questionIds, Long attemptId) {
        if (questionIds.isEmpty()) {
            return List.of();
        }
        return userAnswerMapper.selectLatestByQuestionIdsInAttempt(userId, questionIds, attemptId);
    }

    @Override
    public UserAnswerCounts countByUser(Long userId) {
        return userAnswerMapper.selectCounts(userId);
    }
}
