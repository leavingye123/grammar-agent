package com.grammaragent.grammar.dto;

public record GrammarPointSummaryResponse(
        Long id,
        String code,
        String title,
        String description,
        Integer difficulty,
        Integer sortOrder
) {
}
