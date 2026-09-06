package com.grammaragent.question.repository;

import com.grammaragent.question.entity.UserAnswer;

import java.util.Collection;
import java.util.List;

public interface UserAnswerRepository {

    void insert(UserAnswer userAnswer);

    List<UserAnswer> findLatestByQuestionIdsInAttempt(
            Long userId, Collection<Long> questionIds, Long attemptId);

    UserAnswerCounts countByUser(Long userId);
}
