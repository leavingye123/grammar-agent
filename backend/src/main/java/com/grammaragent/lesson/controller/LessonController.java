package com.grammaragent.lesson.controller;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.lesson.dto.LessonDetailResponse;
import com.grammaragent.lesson.dto.LessonSummaryResponse;
import com.grammaragent.lesson.service.LessonCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequiredArgsConstructor
@Tag(name = "Lessons", description = "Lesson summaries and details")
public class LessonController {

    private final LessonCatalogService lessonCatalogService;

    @GetMapping("/api/v1/grammar-points/{grammarPointId}/lessons")
    @Operation(summary = "List enabled lessons for a grammar point")
    public ApiResponse<List<LessonSummaryResponse>> getLessons(
            @PathVariable @Positive Long grammarPointId) {
        return ApiResponse.success(lessonCatalogService.getLessons(grammarPointId));
    }

    @GetMapping("/api/v1/lessons/{lessonId}")
    @Operation(summary = "Get lesson details without questions")
    public ApiResponse<LessonDetailResponse> getLesson(
            @PathVariable @Positive Long lessonId) {
        return ApiResponse.success(lessonCatalogService.getLesson(lessonId));
    }
}
