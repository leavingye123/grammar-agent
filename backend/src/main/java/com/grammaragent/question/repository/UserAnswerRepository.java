package com.grammaragent.question.repository;

import com.grammaragent.question.entity.UserAnswer;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface UserAnswerRepository {

    // Fail closed for repository implementations without tutor history support.
    default Optional<UserAnswer> findLatestByUserAndQuestion(Long userId, Long questionId) {
        return Optional.empty();
    }

    void insert(UserAnswer userAnswer);

    List<UserAnswer> findLatestByQuestionIdsInAttempt(
            Long userId, Collection<Long> questionIds, Long attemptId);

    UserAnswerCounts countByUser(Long userId);
}
