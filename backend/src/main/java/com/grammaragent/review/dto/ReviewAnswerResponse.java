package com.grammaragent.review.dto;

import com.fasterxml.jackson.databind.JsonNode;

import java.time.OffsetDateTime;

public record ReviewAnswerResponse(
        Long questionId,
        boolean correct,
        JsonNode correctAnswer,
        String explanation,
        boolean mastered,
        int wrongCount,
        OffsetDateTime nextReviewAt,
        int grammarPointMastery
) {
}
