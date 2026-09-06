package com.grammaragent.question.dto;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

public record SubmitAnswerRequest(
        @NotNull JsonNode answer,
        @PositiveOrZero @Max(86_400_000) Integer durationMs
) {
}
