package com.grammaragent.learning.controller;

import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.learning.dto.LessonCompletionResponse;
import com.grammaragent.learning.service.AnswerSubmissionService;
import com.grammaragent.learning.service.LessonCompletionService;
import com.grammaragent.question.dto.SubmitAnswerRequest;
import com.grammaragent.question.dto.SubmitAnswerResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequiredArgsConstructor
@Tag(name = "Learning", description = "Authenticated answer submission and lesson completion")
@SecurityRequirement(name = "bearerAuth")
public class LearningController {

    private final AnswerSubmissionService answerSubmissionService;
    private final LessonCompletionService lessonCompletionService;

    @PostMapping("/api/v1/questions/{questionId}/answer")
    @Operation(summary = "Submit and evaluate one answer")
    public ApiResponse<SubmitAnswerResponse> submitAnswer(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @PathVariable @Positive Long questionId,
            @Valid @RequestBody SubmitAnswerRequest request) {
        return ApiResponse.success(answerSubmissionService.submit(principal.userId(), questionId, request));
    }

    @PostMapping("/api/v1/lessons/{lessonId}/complete")
    @Operation(summary = "Complete a lesson using each question's latest answer")
    public ApiResponse<LessonCompletionResponse> completeLesson(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @PathVariable @Positive Long lessonId) {
        return ApiResponse.success(lessonCompletionService.complete(principal.userId(), lessonId));
    }
}
