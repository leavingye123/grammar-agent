package com.grammaragent.question.controller;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.question.dto.QuestionResponse;
import com.grammaragent.question.service.QuestionQueryService;
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
@Tag(name = "Questions", description = "Public lesson questions without answers or explanations")
public class QuestionController {

    private final QuestionQueryService questionQueryService;

    @GetMapping("/api/v1/lessons/{lessonId}/questions")
    @Operation(summary = "List enabled questions for a lesson")
    public ApiResponse<List<QuestionResponse>> getLessonQuestions(
            @PathVariable @Positive Long lessonId) {
        return ApiResponse.success(questionQueryService.getLessonQuestions(lessonId));
    }
}
