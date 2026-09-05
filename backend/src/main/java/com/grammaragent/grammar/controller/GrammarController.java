package com.grammaragent.grammar.controller;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.grammar.dto.GrammarPointDetailResponse;
import com.grammaragent.grammar.dto.GrammarPointSummaryResponse;
import com.grammaragent.grammar.service.GrammarCatalogService;
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
@Tag(name = "Grammar", description = "Grammar point summaries and details")
public class GrammarController {

    private final GrammarCatalogService grammarCatalogService;

    @GetMapping("/api/v1/chapters/{chapterId}/grammar-points")
    @Operation(summary = "List enabled grammar points in a chapter")
    public ApiResponse<List<GrammarPointSummaryResponse>> getGrammarPoints(
            @PathVariable @Positive Long chapterId) {
        return ApiResponse.success(grammarCatalogService.getGrammarPoints(chapterId));
    }

    @GetMapping("/api/v1/grammar-points/{grammarPointId}")
    @Operation(summary = "Get a grammar point with its prerequisites")
    public ApiResponse<GrammarPointDetailResponse> getGrammarPoint(
            @PathVariable @Positive Long grammarPointId) {
        return ApiResponse.success(grammarCatalogService.getGrammarPoint(grammarPointId));
    }
}
