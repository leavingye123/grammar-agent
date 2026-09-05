package com.grammaragent.course.dto;

public record LanguageResponse(
        Long id,
        String code,
        String name,
        String nativeName
) {
}
