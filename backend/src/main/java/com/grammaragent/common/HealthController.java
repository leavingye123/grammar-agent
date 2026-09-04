package com.grammaragent.common;

import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.common.response.HealthResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health")
@RequiredArgsConstructor
@Tag(name = "Health", description = "Service health endpoints")
public class HealthController {

    private final HealthService healthService;

    @GetMapping
    @Operation(summary = "Get backend health status")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Backend is available")
    public ApiResponse<HealthResponse> health() {
        return ApiResponse.success(healthService.getHealth());
    }
}
