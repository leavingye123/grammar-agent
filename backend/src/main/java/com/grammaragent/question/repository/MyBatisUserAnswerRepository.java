package com.grammaragent.question.repository;

import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.mapper.UserAnswerMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class MyBatisUserAnswerRepository implements UserAnswerRepository {

    private final UserAnswerMapper userAnswerMapper;

    @Override
    public void insert(UserAnswer userAnswer) {
        userAnswerMapper.insert(userAnswer);
    }

    @Override
    public List<UserAnswer> findLatestByQuestionIds(Long userId, Collection<Long> questionIds) {
        if (questionIds.isEmpty()) {
            return List.of();
        }
        return userAnswerMapper.selectLatestByQuestionIds(userId, questionIds);
    }
}
