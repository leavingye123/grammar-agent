package com.grammaragent.review.controller;

import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.question.dto.SubmitAnswerRequest;
import com.grammaragent.review.dto.ReviewAnswerResponse;
import com.grammaragent.review.dto.ReviewQuestionResponse;
import com.grammaragent.review.dto.ReviewSummaryResponse;
import com.grammaragent.review.service.ReviewAnswerService;
import com.grammaragent.review.service.ReviewQueryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/reviews")
@Tag(name = "Review", description = "Authenticated wrong-question review workflow")
@SecurityRequirement(name = "bearerAuth")
public class ReviewController {

    private final ReviewQueryService reviewQueryService;
    private final ReviewAnswerService reviewAnswerService;

    @GetMapping("/due")
    @Operation(summary = "List due unmastered review questions")
    public ApiResponse<List<ReviewQuestionResponse>> getDue(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int limit) {
        return ApiResponse.success(reviewQueryService.getDue(principal.userId(), limit));
    }

    @GetMapping("/wrong-questions")
    @Operation(summary = "List all unmastered wrong questions")
    public ApiResponse<List<ReviewQuestionResponse>> getWrongQuestions(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @RequestParam(defaultValue = "1") @Min(1) @Max(100_000) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return ApiResponse.success(reviewQueryService.getUnmastered(principal.userId(), page, size));
    }

    @GetMapping("/summary")
    @Operation(summary = "Get the current user's review summary")
    public ApiResponse<ReviewSummaryResponse> getSummary(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal) {
        return ApiResponse.success(reviewQueryService.getSummary(principal.userId()));
    }

    @PostMapping("/questions/{questionId}/answer")
    @Operation(summary = "Submit an answer for an unmastered review item")
    public ApiResponse<ReviewAnswerResponse> submitAnswer(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @PathVariable @Positive Long questionId,
            @Valid @RequestBody SubmitAnswerRequest request) {
        return ApiResponse.success(reviewAnswerService.submit(principal.userId(), questionId, request));
    }
}
