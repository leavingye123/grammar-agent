package com.grammaragent.grammar.dto;

import com.fasterxml.jackson.databind.JsonNode;

import java.util.List;

public record GrammarPointDetailResponse(
        Long id,
        Long chapterId,
        String code,
        String title,
        String description,
        String grammarRule,
        JsonNode examples,
        JsonNode commonErrors,
        Integer difficulty,
        Integer sortOrder,
        List<PrerequisiteResponse> prerequisites
) {
}
