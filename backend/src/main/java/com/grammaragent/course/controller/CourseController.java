package com.grammaragent.course.controller;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.course.dto.ChapterResponse;
import com.grammaragent.course.service.CourseCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequestMapping("/api/v1/levels")
@RequiredArgsConstructor
@Tag(name = "Course", description = "Course chapters")
public class CourseController {

    private final CourseCatalogService courseCatalogService;

    @GetMapping("/{levelId}/chapters")
    @Operation(summary = "List enabled chapters for a language level")
    public ApiResponse<List<ChapterResponse>> getChapters(
            @PathVariable @Positive Long levelId) {
        return ApiResponse.success(courseCatalogService.getChapters(levelId));
    }
}
