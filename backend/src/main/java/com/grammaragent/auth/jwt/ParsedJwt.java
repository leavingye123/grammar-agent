package com.grammaragent.auth.jwt;

import java.time.Instant;

public record ParsedJwt(Long userId, String tokenId, TokenType tokenType, Instant expiresAt) {
}
