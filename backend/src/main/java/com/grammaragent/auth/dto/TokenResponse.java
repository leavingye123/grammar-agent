package com.grammaragent.auth.dto;

import com.grammaragent.auth.jwt.JwtProperties;
import com.grammaragent.auth.jwt.JwtTokenPair;

public record TokenResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        long accessExpiresIn,
        long refreshExpiresIn
) {
    public static TokenResponse from(JwtTokenPair tokenPair, JwtProperties properties) {
        return new TokenResponse(
                tokenPair.accessToken().value(),
                tokenPair.refreshToken().value(),
                "Bearer",
                properties.accessExpire(),
                properties.refreshExpire());
    }
}
