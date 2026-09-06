package com.grammaragent.question.repository;

import java.time.OffsetDateTime;

public interface WrongQuestionRepository {

    void recordWrong(
            Long userId,
            Long questionId,
            OffsetDateTime wrongAt,
            OffsetDateTime nextReviewAt);
}
