package com.grammaragent.auth.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.auth.controller.AuthController;
import com.grammaragent.auth.jwt.JwtTokenService;
import com.grammaragent.auth.service.AuthService;
import com.grammaragent.auth.session.RefreshSessionStore;
import com.grammaragent.common.exception.GlobalExceptionHandler;
import com.grammaragent.config.SecurityConfig;
import com.grammaragent.user.controller.UserController;
import com.grammaragent.user.dto.UserProfileResponse;
import com.grammaragent.user.entity.User;
import com.grammaragent.user.mapper.UserProfileMapper;
import com.grammaragent.user.repository.UserRepository;
import com.grammaragent.user.service.UserProfileService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.TestExecutionListeners;
import org.springframework.test.context.event.ApplicationEventsTestExecutionListener;
import org.springframework.test.context.event.EventPublishingTestExecutionListener;
import org.springframework.test.context.support.DependencyInjectionTestExecutionListener;
import org.springframework.test.context.support.DirtiesContextBeforeModesTestExecutionListener;
import org.springframework.test.context.support.DirtiesContextTestExecutionListener;
import org.springframework.test.context.web.ServletTestExecutionListener;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(
        controllers = {AuthController.class, UserController.class},
        properties = {
                "app.jwt.secret=test-secret-that-is-at-least-thirty-two-bytes-long",
                "app.jwt.access-expire=900",
                "app.jwt.refresh-expire=3600"
        })
@Import({
        SecurityConfig.class,
        JwtTokenService.class,
        JwtAuthenticationFilter.class,
        SecurityErrorResponseWriter.class,
        RestAuthenticationEntryPoint.class,
        RestAccessDeniedHandler.class,
        AuthService.class,
        UserProfileService.class,
        GlobalExceptionHandler.class,
        SecurityConfigurationIntegrationTest.TestBeans.class
})
@TestExecutionListeners(
        listeners = {
                ServletTestExecutionListener.class,
                DirtiesContextBeforeModesTestExecutionListener.class,
                ApplicationEventsTestExecutionListener.class,
                DependencyInjectionTestExecutionListener.class,
                DirtiesContextTestExecutionListener.class,
                EventPublishingTestExecutionListener.class
        },
        inheritListeners = false)
class SecurityConfigurationIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void publicAuthEndpointsShouldReachControllerAndProtectedEndpointShouldRequireToken() throws Exception {
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType("application/json")
                        .content("{\"email\":\"missing@example.com\",\"password\":\"Wrong123!\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40101));

        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType("application/json")
                        .content("{\"refreshToken\":\"not-a-jwt\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40105));

        mockMvc.perform(get("/api/v1/users/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));
    }

    @Test
    void registrationShouldBePublicAndIssuedAccessTokenShouldAuthenticateCurrentUser() throws Exception {
        String registrationBody = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType("application/json")
                        .content("{\"email\":\"security@example.com\","
                                + "\"username\":\"Security Test\",\"password\":\"Password123!\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value(0))
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode registration = objectMapper.readTree(registrationBody);
        String accessToken = registration.path("data").path("tokens").path("accessToken").asText();

        mockMvc.perform(get("/api/v1/users/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.email").value("security@example.com"));
    }

    @TestConfiguration
    static class TestBeans {

        @Bean
        UserRepository userRepository() {
            return new InMemoryUserRepository();
        }

        @Bean
        RefreshSessionStore refreshSessionStore() {
            return new RefreshSessionStore() {
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
            };
        }

        @Bean
        UserProfileMapper userProfileMapper() {
            return user -> new UserProfileResponse(
                    user.getId(),
                    user.getEmail(),
                    user.getUsername(),
                    user.getAvatarUrl(),
                    user.getNativeLanguage(),
                    user.getStatus(),
                    user.getCreatedAt());
        }
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
}
