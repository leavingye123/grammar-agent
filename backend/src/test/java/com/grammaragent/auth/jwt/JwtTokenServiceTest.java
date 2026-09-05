package com.grammaragent.auth.jwt;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class JwtTokenServiceTest {

    private static final String SECRET = "test-secret-that-is-at-least-thirty-two-bytes-long";

    @Test
    void shouldIssueAndParseDifferentAccessAndRefreshTokens() {
        JwtTokenService service = new JwtTokenService(new JwtProperties(SECRET, 900, 3600));

        JwtTokenPair pair = service.issueTokenPair(42L);

        assertNotEquals(pair.accessToken().value(), pair.refreshToken().value());
        assertEquals(42L, service.parseAccessToken(pair.accessToken().value()).userId());
        assertEquals(TokenType.ACCESS, service.parseAccessToken(pair.accessToken().value()).tokenType());
        assertEquals(TokenType.REFRESH, service.parseRefreshToken(pair.refreshToken().value()).tokenType());
    }

    @Test
    void shouldRejectRefreshTokenAsAccessToken() {
        JwtTokenService service = new JwtTokenService(new JwtProperties(SECRET, 900, 3600));
        JwtTokenPair pair = service.issueTokenPair(42L);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> service.parseAccessToken(pair.refreshToken().value()));

        assertEquals(ErrorCode.ACCESS_TOKEN_INVALID, exception.getErrorCode());
    }

    @Test
    void shouldRejectTamperedToken() {
        JwtTokenService service = new JwtTokenService(new JwtProperties(SECRET, 900, 3600));
        String token = service.issueTokenPair(42L).accessToken().value();
        String tampered = token.substring(0, token.length() - 1)
                + (token.endsWith("a") ? "b" : "a");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> service.parseAccessToken(tampered));

        assertEquals(ErrorCode.ACCESS_TOKEN_INVALID, exception.getErrorCode());
    }

    @Test
    void shouldReportExpiredAccessToken() {
        Clock oldClock = Clock.fixed(Instant.parse("2020-01-01T00:00:00Z"), ZoneOffset.UTC);
        JwtTokenService service = new JwtTokenService(new JwtProperties(SECRET, 1, 3600), oldClock);
        String token = service.issueTokenPair(42L).accessToken().value();

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> service.parseAccessToken(token));

        assertEquals(ErrorCode.ACCESS_TOKEN_EXPIRED, exception.getErrorCode());
    }
}
