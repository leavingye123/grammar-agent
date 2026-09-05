package com.grammaragent.course.controller;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.course.dto.LearningPathResponse;
import com.grammaragent.course.service.LearningPathService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/learning-path")
@RequiredArgsConstructor
@Tag(name = "Learning Path", description = "Public course trees for learning maps")
public class LearningPathController {

    private final LearningPathService learningPathService;

    @GetMapping("/{languageCode}")
    @Operation(summary = "Get the complete enabled course tree for a language")
    public ApiResponse<LearningPathResponse> getLearningPath(
            @PathVariable String languageCode) {
        return ApiResponse.success(learningPathService.getLearningPath(languageCode));
    }
}
