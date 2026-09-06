package com.grammaragent.question.repository;

import com.grammaragent.question.mapper.WrongQuestionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;

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
}
