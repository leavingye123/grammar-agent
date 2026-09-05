package com.grammaragent.auth.controller;

import com.grammaragent.auth.dto.AuthResponse;
import com.grammaragent.auth.dto.LoginRequest;
import com.grammaragent.auth.dto.LogoutRequest;
import com.grammaragent.auth.dto.RefreshTokenRequest;
import com.grammaragent.auth.dto.RegisterRequest;
import com.grammaragent.auth.dto.TokenResponse;
import com.grammaragent.auth.security.AuthenticatedUserPrincipal;
import com.grammaragent.auth.service.AuthService;
import com.grammaragent.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Auth", description = "Registration, login, token refresh, and logout")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "Register with email and password")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(authService.register(request)));
    }

    @PostMapping("/login")
    @Operation(summary = "Log in with email and password")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success(authService.login(request));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rotate a refresh token and issue a new token pair")
    public ApiResponse<TokenResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ApiResponse.success(authService.refresh(request.refreshToken()));
    }

    @PostMapping("/logout")
    @Operation(summary = "Revoke the supplied refresh session")
    @SecurityRequirement(name = "bearerAuth")
    public ApiResponse<Void> logout(
            @AuthenticationPrincipal AuthenticatedUserPrincipal principal,
            @Valid @RequestBody LogoutRequest request) {
        authService.logout(principal.userId(), request.refreshToken());
        return ApiResponse.success(null);
    }
}
