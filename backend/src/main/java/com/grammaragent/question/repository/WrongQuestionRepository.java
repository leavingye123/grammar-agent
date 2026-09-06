package com.grammaragent.question.repository;

import com.grammaragent.question.entity.WrongQuestion;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

public interface WrongQuestionRepository {

    void recordWrong(
            Long userId,
            Long questionId,
            OffsetDateTime wrongAt,
            OffsetDateTime nextReviewAt);

    List<WrongQuestion> findDueByUserId(Long userId, OffsetDateTime now, int limit);

    List<WrongQuestion> findUnmasteredByUserId(Long userId, int offset, int limit);

    WrongQuestionSummary summarize(Long userId, OffsetDateTime now);

    Optional<WrongQuestion> findForUpdate(Long userId, Long questionId);

    void updateReviewResult(WrongQuestion wrongQuestion, OffsetDateTime updatedAt);
}
