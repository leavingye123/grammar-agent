package com.grammaragent.auth.jwt;

public record JwtTokenPair(IssuedJwt accessToken, IssuedJwt refreshToken) {
}
