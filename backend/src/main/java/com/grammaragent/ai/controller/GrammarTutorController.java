package com.grammaragent.ai.controller;

import com.grammaragent.ai.dto.GrammarTutorChatRequest;
import com.grammaragent.ai.dto.GrammarTutorChatResponse;
import com.grammaragent.ai.service.GrammarTutorService;
import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/ai/tutor")
@RequiredArgsConstructor
public class GrammarTutorController {
    private final GrammarTutorService service;

    @PostMapping("/chat")
    public ApiResponse<GrammarTutorChatResponse> chat(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @Valid @RequestBody GrammarTutorChatRequest request) {
        return ApiResponse.success(service.chat(principal == null ? null : principal.userId(), request));
    }

    // Read-only capability + deterministic templates, without any provider call or course answers.
    @GetMapping("/status")
    public ApiResponse<GrammarTutorService.TutorStatus> status(
            @RequestParam(defaultValue = "teaching") String scene,
            @RequestParam(required = false) Long lessonAttemptId,
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal) {
        if (lessonAttemptId != null || "result".equals(scene)) {
            return ApiResponse.success(service.resultStatus(principal == null ? null : principal.userId(), lessonAttemptId));
        }
        return ApiResponse.success(service.status(scene));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> invalidRequest() {
        return ResponseEntity.badRequest().body(ApiResponse.error(ErrorCode.VALIDATION_ERROR));
    }
}
