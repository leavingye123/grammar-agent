package com.grammaragent.review.dto;

import com.grammaragent.question.dto.QuestionResponse;

import java.time.OffsetDateTime;

public record ReviewQuestionResponse(
        Long wrongQuestionId,
        QuestionResponse question,
        int wrongCount,
        OffsetDateTime lastWrongAt,
        OffsetDateTime nextReviewAt
) {
}
