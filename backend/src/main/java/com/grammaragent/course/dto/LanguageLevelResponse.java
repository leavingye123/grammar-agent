package com.grammaragent.course.dto;

public record LanguageLevelResponse(
        Long id,
        String code,
        String name,
        String description,
        Integer sortOrder
) {
}
