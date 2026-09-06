package com.grammaragent.dashboard.controller;

import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.dashboard.dto.DashboardResponse;
import com.grammaragent.dashboard.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Dashboard", description = "Authenticated home dashboard aggregate")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping
    @Operation(summary = "Get the authenticated user's home dashboard")
    public ApiResponse<DashboardResponse> getDashboard(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal) {
        return ApiResponse.success(dashboardService.getDashboard(principal.userId()));
    }
}
