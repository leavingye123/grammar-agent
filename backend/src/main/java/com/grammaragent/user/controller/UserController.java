package com.grammaragent.user.controller;

import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.common.response.ApiResponse;
import com.grammaragent.user.dto.UserProfileResponse;
import com.grammaragent.user.service.UserProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "User", description = "Authenticated user profile endpoints")
public class UserController {

    private final UserProfileService userProfileService;

    @GetMapping("/me")
    @Operation(summary = "Get the authenticated user's profile")
    public ApiResponse<UserProfileResponse> me(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal) {
        return ApiResponse.success(userProfileService.getProfile(principal.userId()));
    }
}
