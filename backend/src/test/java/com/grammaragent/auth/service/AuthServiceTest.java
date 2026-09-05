package com.grammaragent.auth.service;

import com.grammaragent.auth.dto.AuthResponse;
import com.grammaragent.auth.dto.LoginRequest;
import com.grammaragent.auth.dto.RegisterRequest;
import com.grammaragent.auth.dto.TokenResponse;
import com.grammaragent.auth.jwt.JwtProperties;
import com.grammaragent.auth.jwt.JwtTokenService;
import com.grammaragent.auth.jwt.ParsedJwt;
import com.grammaragent.auth.session.RefreshSessionStore;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.user.dto.UserProfileResponse;
import com.grammaragent.user.entity.User;
import com.grammaragent.user.enums.UserStatus;
import com.grammaragent.user.mapper.UserProfileMapper;
import com.grammaragent.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AuthServiceTest {

    private static final String SECRET = "test-secret-that-is-at-least-thirty-two-bytes-long";
    private static final JwtProperties JWT_PROPERTIES = new JwtProperties(SECRET, 900, 3600);

    private InMemoryUserRepository userRepository;
    private InMemoryRefreshSessionStore sessionStore;
    private JwtTokenService tokenService;
    private BCryptPasswordEncoder passwordEncoder;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        userRepository = new InMemoryUserRepository();
        sessionStore = new InMemoryRefreshSessionStore();
        tokenService = new JwtTokenService(JWT_PROPERTIES);
        passwordEncoder = new BCryptPasswordEncoder(4);
        authService = new AuthService(
                userRepository,
                AuthServiceTest::toProfile,
                passwordEncoder,
                tokenService,
                JWT_PROPERTIES,
                sessionStore);
    }

    @Test
    void shouldRegisterNormalizedEmailAndStoreOnlyPasswordHash() {
        AuthResponse response = authService.register(
                new RegisterRequest("  Learner@Example.COM ", " Learner ", "Password123"));

        User saved = userRepository.findByEmailIgnoreCase("learner@example.com").orElseThrow();
        assertEquals("learner@example.com", saved.getEmail());
        assertEquals("Learner", saved.getUsername());
        assertNotEquals("Password123", saved.getPasswordHash());
        assertTrue(passwordEncoder.matches("Password123", saved.getPasswordHash()));
        assertNotNull(response.tokens().accessToken());
        assertNotNull(response.tokens().refreshToken());
    }

    @Test
    void shouldRejectDuplicateEmailIgnoringCase() {
        authService.register(new RegisterRequest("learner@example.com", "Learner", "Password123"));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.register(
                        new RegisterRequest("LEARNER@example.com", "Other", "Password123")));

        assertEquals(ErrorCode.EMAIL_ALREADY_EXISTS, exception.getErrorCode());
    }

    @Test
    void shouldLoginAndRejectWrongPasswordWithoutRevealingWhichCredentialFailed() {
        authService.register(new RegisterRequest("learner@example.com", "Learner", "Password123"));

        AuthResponse login = authService.login(new LoginRequest("LEARNER@example.com", "Password123"));
        BusinessException wrongPassword = assertThrows(
                BusinessException.class,
                () -> authService.login(new LoginRequest("learner@example.com", "wrong")));
        BusinessException unknownEmail = assertThrows(
                BusinessException.class,
                () -> authService.login(new LoginRequest("unknown@example.com", "Password123")));

        assertNotNull(login.tokens().accessToken());
        assertNotNull(userRepository.findByEmailIgnoreCase("learner@example.com").orElseThrow().getLastLoginAt());
        assertEquals(ErrorCode.INVALID_CREDENTIALS, wrongPassword.getErrorCode());
        assertEquals(ErrorCode.INVALID_CREDENTIALS, unknownEmail.getErrorCode());
    }

    @Test
    void shouldRotateRefreshTokenAndRejectReuse() {
        AuthResponse registration = authService.register(
                new RegisterRequest("learner@example.com", "Learner", "Password123"));
        String originalRefreshToken = registration.tokens().refreshToken();

        TokenResponse rotated = authService.refresh(originalRefreshToken);
        BusinessException reused = assertThrows(
                BusinessException.class,
                () -> authService.refresh(originalRefreshToken));

        assertNotEquals(originalRefreshToken, rotated.refreshToken());
        assertEquals(ErrorCode.REFRESH_TOKEN_REVOKED, reused.getErrorCode());
    }

    @Test
    void shouldRevokeRefreshTokenOnLogout() {
        AuthResponse registration = authService.register(
                new RegisterRequest("learner@example.com", "Learner", "Password123"));
        String refreshToken = registration.tokens().refreshToken();
        ParsedJwt parsedRefresh = tokenService.parseRefreshToken(refreshToken);

        authService.logout(registration.user().id(), refreshToken);

        assertFalse(sessionStore.contains(parsedRefresh.tokenId()));
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.refresh(refreshToken));
        assertEquals(ErrorCode.REFRESH_TOKEN_REVOKED, exception.getErrorCode());
    }

    private static UserProfileResponse toProfile(User user) {
        return new UserProfileResponse(
                user.getId(),
                user.getEmail(),
                user.getUsername(),
                user.getAvatarUrl(),
                user.getNativeLanguage(),
                user.getStatus(),
                user.getCreatedAt());
    }

    private static final class InMemoryUserRepository implements UserRepository {

        private final AtomicLong sequence = new AtomicLong();
        private final Map<Long, User> users = new HashMap<>();

        @Override
        public Optional<User> findByEmailIgnoreCase(String normalizedEmail) {
            return users.values().stream()
                    .filter(user -> user.getEmail().equalsIgnoreCase(normalizedEmail))
                    .findFirst();
        }

        @Override
        public Optional<User> findById(Long userId) {
            return Optional.ofNullable(users.get(userId));
        }

        @Override
        public User insert(User user) {
            user.setId(sequence.incrementAndGet());
            OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
            user.setCreatedAt(now);
            user.setUpdatedAt(now);
            users.put(user.getId(), user);
            return user;
        }

        @Override
        public void update(User user) {
            users.put(user.getId(), user);
        }
    }

    private static final class InMemoryRefreshSessionStore implements RefreshSessionStore {

        private final Map<String, Long> sessions = new HashMap<>();

        @Override
        public void save(String tokenId, Long userId, Instant expiresAt) {
            sessions.put(tokenId, userId);
        }

        @Override
        public Optional<Long> consume(String tokenId) {
            return Optional.ofNullable(sessions.remove(tokenId));
        }

        @Override
        public void revoke(String tokenId) {
            sessions.remove(tokenId);
        }

        boolean contains(String tokenId) {
            return sessions.containsKey(tokenId);
        }
    }
}
