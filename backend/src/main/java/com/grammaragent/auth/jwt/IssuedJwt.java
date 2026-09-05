package com.grammaragent.auth.jwt;

import java.time.Instant;

public record IssuedJwt(String value, String tokenId, Instant expiresAt) {
}
