package com.grammaragent.question.dto;

import com.fasterxml.jackson.databind.JsonNode;

public record SubmitAnswerResponse(
        Long questionId,
        boolean correct,
        JsonNode correctAnswer,
        String explanation,
        int xpEarned,
        int grammarPointMastery
) {
}
