package com.grammaragent.course.dto;

public record ChapterResponse(
        Long id,
        String title,
        String description,
        Integer sortOrder
) {
}
