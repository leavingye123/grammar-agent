package com.grammaragent.auth.session;

import java.time.Instant;
import java.util.Optional;

public interface RefreshSessionStore {

    void save(String tokenId, Long userId, Instant expiresAt);

    Optional<Long> consume(String tokenId);

    void revoke(String tokenId);
}
