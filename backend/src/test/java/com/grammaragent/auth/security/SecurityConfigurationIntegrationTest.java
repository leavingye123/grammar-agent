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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(
        controllers = {
                AuthController.class,
                UserController.class,
                SecurityConfigurationIntegrationTest.PublicCatalogProbeController.class
        },
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
        SecurityConfigurationIntegrationTest.PublicCatalogProbeController.class,
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
    void tutorEndpointsRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/ai/tutor/status"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));
        mockMvc.perform(post("/api/v1/ai/tutor/chat")
                        .contentType("application/json")
                        .content("{\"grammarPointId\":16,\"message\":\"why\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));
    }

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

    @Test
    void publicCatalogGetShouldAllowAnonymousWhileCurrentUserStillRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/languages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));

        mockMvc.perform(get("/api/v1/users/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));
    }

    @Test
    void questionsShouldBePublicButLearningWritesShouldRequireAccessToken() throws Exception {
        mockMvc.perform(get("/api/v1/lessons/1/questions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data[0].correctAnswer").doesNotExist())
                .andExpect(jsonPath("$.data[0].explanation").doesNotExist());

        mockMvc.perform(post("/api/v1/questions/1/answer")
                        .contentType("application/json")
                        .content("{\"answer\":\"A\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(post("/api/v1/lessons/1/complete"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(post("/api/v1/questions/1/answer")
                        .header("Authorization", "Bearer invalid-token")
                        .contentType("application/json")
                        .content("{\"answer\":\"A\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40103));
    }

    @Test
    void newDashboardAndStatefulPathEndpointsShouldRequireTokenButPublicPathStaysOpen() throws Exception {
        mockMvc.perform(get("/api/v1/dashboard"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(get("/api/v1/learning-path/en/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(get("/api/v1/lessons/1/attempts"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(get("/api/v1/learning-path/en"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));
    }

    @Test
    void validTokenShouldReachNewAuthenticatedEndpoints() throws Exception {
        String registrationBody = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType("application/json")
                        .content("{\"email\":\"dashboard@example.com\","
                                + "\"username\":\"Dashboard\",\"password\":\"Password123!\"}"))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();
        String accessToken = objectMapper.readTree(registrationBody)
                .path("data").path("tokens").path("accessToken").asText();
        String bearer = "Bearer " + accessToken;

        mockMvc.perform(get("/api/v1/dashboard").header("Authorization", bearer))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));

        mockMvc.perform(get("/api/v1/learning-path/en/me").header("Authorization", bearer))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));

        mockMvc.perform(get("/api/v1/lessons/1/attempts").header("Authorization", bearer))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));
    }

    @Test
    void allReviewEndpointsShouldRequireAccessToken() throws Exception {
        mockMvc.perform(get("/api/v1/reviews/due"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(get("/api/v1/reviews/wrong-questions"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(get("/api/v1/reviews/summary"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(post("/api/v1/reviews/questions/1/answer")
                        .contentType("application/json")
                        .content("{\"answer\":\"A\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40100));

        mockMvc.perform(get("/api/v1/reviews/due")
                        .header("Authorization", "Bearer invalid-token"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value(40103));
    }

    @RestController
    static class PublicCatalogProbeController {

        @GetMapping("/api/v1/languages")
        public Map<String, Object> languages() {
            return Map.of("code", 0, "data", List.of());
        }

        @GetMapping("/api/v1/learning-path/en")
        public Map<String, Object> learningPath() {
            return Map.of("code", 0, "data", Map.of());
        }

        @GetMapping("/api/v1/learning-path/en/me")
        public Map<String, Object> myLearningPath() {
            return Map.of("code", 0, "data", Map.of());
        }

        @GetMapping("/api/v1/dashboard")
        public Map<String, Object> dashboard() {
            return Map.of("code", 0, "data", Map.of());
        }

        @GetMapping("/api/v1/lessons/1/attempts")
        public Map<String, Object> attempts() {
            return Map.of("code", 0, "data", List.of());
        }

        @GetMapping("/api/v1/lessons/1/questions")
        public Map<String, Object> questions() {
            return Map.of(
                    "code", 0,
                    "data", List.of(Map.of(
                            "id", 1,
                            "questionType", "SINGLE_CHOICE",
                            "questionContent", "I ___ a student.",
                            "options", List.of("A", "B", "C"))));
        }

        @PostMapping("/api/v1/questions/1/answer")
        public Map<String, Object> answer() {
            return Map.of("code", 0);
        }

        @PostMapping("/api/v1/lessons/1/complete")
        public Map<String, Object> complete() {
            return Map.of("code", 0);
        }

        @GetMapping("/api/v1/reviews/due")
        public Map<String, Object> dueReviews() {
            return Map.of("code", 0, "data", List.of());
        }

        @GetMapping("/api/v1/reviews/wrong-questions")
        public Map<String, Object> wrongQuestions() {
            return Map.of("code", 0, "data", List.of());
        }

        @GetMapping("/api/v1/reviews/summary")
        public Map<String, Object> reviewSummary() {
            return Map.of("code", 0, "data", Map.of());
        }

        @PostMapping("/api/v1/reviews/questions/1/answer")
        public Map<String, Object> reviewAnswer() {
            return Map.of("code", 0);
        }
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
