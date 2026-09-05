package com.grammaragent.auth.session;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class RedisRefreshSessionStore implements RefreshSessionStore {

    public static final String KEY_PREFIX = "auth:refresh:";

    private final StringRedisTemplate redisTemplate;

    @Override
    public void save(String tokenId, Long userId, Instant expiresAt) {
        Duration ttl = Duration.between(Instant.now(), expiresAt);
        if (ttl.isZero() || ttl.isNegative()) {
            throw new IllegalArgumentException("Refresh session expiration must be in the future");
        }
        redisTemplate.opsForValue().set(key(tokenId), userId.toString(), ttl);
    }

    @Override
    public Optional<Long> consume(String tokenId) {
        String userId = redisTemplate.opsForValue().getAndDelete(key(tokenId));
        return Optional.ofNullable(userId).map(Long::valueOf);
    }

    @Override
    public void revoke(String tokenId) {
        redisTemplate.delete(key(tokenId));
    }

    private String key(String tokenId) {
        return KEY_PREFIX + tokenId;
    }
}
