package com.grammaragent.auth.jwt;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtTokenService {

    private static final String USER_ID_CLAIM = "userId";
    private static final String TOKEN_TYPE_CLAIM = "tokenType";

    private final JwtProperties properties;
    private final Clock clock;
    private final SecretKey signingKey;
    private final JwtParser parser;

    @Autowired
    public JwtTokenService(JwtProperties properties) {
        this(properties, Clock.systemUTC());
    }

    JwtTokenService(JwtProperties properties, Clock clock) {
        this.properties = properties;
        this.clock = clock;
        byte[] secretBytes = properties.secret().getBytes(StandardCharsets.UTF_8);
        if (secretBytes.length < 32) {
            throw new IllegalStateException("JWT secret must contain at least 32 UTF-8 bytes");
        }
        this.signingKey = Keys.hmacShaKeyFor(secretBytes);
        this.parser = Jwts.parser().verifyWith(signingKey).build();
    }

    public JwtTokenPair issueTokenPair(Long userId) {
        return new JwtTokenPair(
                issueToken(userId, TokenType.ACCESS, properties.accessExpire()),
                issueToken(userId, TokenType.REFRESH, properties.refreshExpire()));
    }

    public ParsedJwt parseAccessToken(String token) {
        return parseToken(token, TokenType.ACCESS);
    }

    public ParsedJwt parseRefreshToken(String token) {
        return parseToken(token, TokenType.REFRESH);
    }

    private IssuedJwt issueToken(Long userId, TokenType tokenType, long expiresInSeconds) {
        Instant issuedAt = clock.instant();
        Instant expiresAt = issuedAt.plusSeconds(expiresInSeconds);
        String tokenId = UUID.randomUUID().toString();

        String value = Jwts.builder()
                .id(tokenId)
                .subject(userId.toString())
                .claim(USER_ID_CLAIM, userId)
                .claim(TOKEN_TYPE_CLAIM, tokenType.name())
                .issuedAt(Date.from(issuedAt))
                .expiration(Date.from(expiresAt))
                .signWith(signingKey)
                .compact();

        return new IssuedJwt(value, tokenId, expiresAt);
    }

    private ParsedJwt parseToken(String token, TokenType expectedType) {
        try {
            Claims claims = parser.parseSignedClaims(token).getPayload();
            TokenType actualType = TokenType.valueOf(claims.get(TOKEN_TYPE_CLAIM, String.class));
            if (actualType != expectedType) {
                throw new BusinessException(invalidCode(expectedType));
            }

            Object userIdClaim = claims.get(USER_ID_CLAIM);
            Long userId = Long.valueOf(userIdClaim.toString());
            String tokenId = claims.getId();
            if (tokenId == null || tokenId.isBlank()) {
                throw new BusinessException(invalidCode(expectedType));
            }

            return new ParsedJwt(userId, tokenId, actualType, claims.getExpiration().toInstant());
        } catch (ExpiredJwtException exception) {
            throw new BusinessException(expiredCode(expectedType));
        } catch (BusinessException exception) {
            throw exception;
        } catch (JwtException | IllegalArgumentException | NullPointerException exception) {
            throw new BusinessException(invalidCode(expectedType));
        }
    }

    private ErrorCode expiredCode(TokenType tokenType) {
        return tokenType == TokenType.ACCESS
                ? ErrorCode.ACCESS_TOKEN_EXPIRED
                : ErrorCode.REFRESH_TOKEN_EXPIRED;
    }

    private ErrorCode invalidCode(TokenType tokenType) {
        return tokenType == TokenType.ACCESS
                ? ErrorCode.ACCESS_TOKEN_INVALID
                : ErrorCode.REFRESH_TOKEN_INVALID;
    }
}
