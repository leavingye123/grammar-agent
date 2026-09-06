package com.grammaragent.question.repository;

import com.grammaragent.question.mapper.WrongQuestionMapper;
import com.grammaragent.question.entity.WrongQuestion;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MyBatisWrongQuestionRepository implements WrongQuestionRepository {

    private final WrongQuestionMapper mapper;

    @Override
    public void recordWrong(
            Long userId,
            Long questionId,
            OffsetDateTime wrongAt,
            OffsetDateTime nextReviewAt) {
        mapper.upsertWrong(userId, questionId, wrongAt, nextReviewAt);
    }

    @Override
    public List<WrongQuestion> findDueByUserId(Long userId, OffsetDateTime now, int limit) {
        return mapper.selectDueByUserId(userId, now, limit);
    }

    @Override
    public List<WrongQuestion> findUnmasteredByUserId(Long userId, int offset, int limit) {
        return mapper.selectUnmasteredByUserId(userId, offset, limit);
    }

    @Override
    public WrongQuestionSummary summarize(Long userId, OffsetDateTime now) {
        return mapper.selectSummary(userId, now);
    }

    @Override
    public Optional<WrongQuestion> findForUpdate(Long userId, Long questionId) {
        return Optional.ofNullable(mapper.selectForUpdate(userId, questionId));
    }

    @Override
    public void updateReviewResult(WrongQuestion wrongQuestion, OffsetDateTime updatedAt) {
        mapper.updateReviewResult(wrongQuestion, updatedAt);
    }
}
