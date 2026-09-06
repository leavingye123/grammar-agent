package com.grammaragent.course.controller;

import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.course.dto.LearningPathResponse;
import com.grammaragent.course.service.LearningPathService;
import com.grammaragent.course.service.UserLearningPathService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/learning-path")
@RequiredArgsConstructor
@Tag(name = "Learning Path", description = "Course trees for learning maps")
public class LearningPathController {

    private final LearningPathService learningPathService;
    private final UserLearningPathService userLearningPathService;

    @GetMapping("/{languageCode}")
    @Operation(summary = "Get the complete enabled course tree for a language")
    public ApiResponse<LearningPathResponse> getLearningPath(
            @PathVariable String languageCode) {
        return ApiResponse.success(learningPathService.getLearningPath(languageCode));
    }

    @GetMapping("/{languageCode}/me")
    @Operation(summary = "Get the authenticated user's stateful course tree")
    @SecurityRequirement(name = "bearerAuth")
    public ApiResponse<LearningPathResponse> getMyLearningPath(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @PathVariable String languageCode) {
        return ApiResponse.success(userLearningPathService.getUserLearningPath(principal.userId(), languageCode));
    }
}
