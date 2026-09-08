package com.grammaragent.question.dto;

import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.question.enums.QuestionType;

public record QuestionResponse(
        Long id,
        String questionCode,
        QuestionType questionType,
        String questionContent,
        JsonNode options,
        Integer difficulty,
        Integer sortOrder
) {
}
