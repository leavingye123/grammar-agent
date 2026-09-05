package com.grammaragent.course.controller;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.course.dto.LanguageLevelResponse;
import com.grammaragent.course.dto.LanguageResponse;
import com.grammaragent.course.service.CourseCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/languages")
@RequiredArgsConstructor
@Tag(name = "Languages", description = "Available learning languages and proficiency levels")
public class LanguageController {

    private final CourseCatalogService courseCatalogService;

    @GetMapping
    @Operation(summary = "List enabled languages")
    public ApiResponse<List<LanguageResponse>> getLanguages() {
        return ApiResponse.success(courseCatalogService.getLanguages());
    }

    @GetMapping("/{languageCode}/levels")
    @Operation(summary = "List levels for an enabled language")
    public ApiResponse<List<LanguageLevelResponse>> getLevels(
            @PathVariable String languageCode) {
        return ApiResponse.success(courseCatalogService.getLevels(languageCode));
    }
}
