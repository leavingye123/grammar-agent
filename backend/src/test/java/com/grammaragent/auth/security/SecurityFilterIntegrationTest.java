package com.grammaragent.auth.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.auth.jwt.JwtProperties;
import com.grammaragent.auth.jwt.JwtTokenPair;
import com.grammaragent.auth.jwt.JwtTokenService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SecurityFilterIntegrationTest {

    private JwtTokenService jwtTokenService;
    private JwtAuthenticationFilter filter;
    private RestAuthenticationEntryPoint authenticationEntryPoint;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper().findAndRegisterModules();
        jwtTokenService = new JwtTokenService(new JwtProperties(
                "test-secret-that-is-at-least-thirty-two-bytes-long", 900, 3600));
        SecurityErrorResponseWriter writer = new SecurityErrorResponseWriter(objectMapper);
        filter = new JwtAuthenticationFilter(jwtTokenService, writer);
        authenticationEntryPoint = new RestAuthenticationEntryPoint(writer);
    }

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void shouldAuthenticateValidAccessTokenAndPopulateSecurityContext() throws Exception {
        JwtTokenPair tokens = jwtTokenService.issueTokenPair(7L);
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/v1/users/me");
        request.addHeader("Authorization", "Bearer " + tokens.accessToken().value());
        MockHttpServletResponse response = new MockHttpServletResponse();
        AtomicReference<Authentication> downstreamAuthentication = new AtomicReference<>();

        filter.doFilter(request, response, (servletRequest, servletResponse) ->
                downstreamAuthentication.set(SecurityContextHolder.getContext().getAuthentication()));

        Authentication authentication = downstreamAuthentication.get();
        AuthenticatedUserPrincipal principal = assertInstanceOf(
                AuthenticatedUserPrincipal.class, authentication.getPrincipal());
        assertEquals(7L, principal.userId());
        assertEquals(200, response.getStatus());
    }

    @Test
    void shouldPassMissingTokenForSecurityChainToDecide() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/v1/users/me");
        MockHttpServletResponse response = new MockHttpServletResponse();
        AtomicReference<Authentication> downstreamAuthentication = new AtomicReference<>();

        filter.doFilter(request, response, (servletRequest, servletResponse) ->
                downstreamAuthentication.set(SecurityContextHolder.getContext().getAuthentication()));

        assertNull(downstreamAuthentication.get());
        assertEquals(200, response.getStatus());
    }

    @Test
    void shouldNotFilterPublicLoginEvenWhenAuthorizationHeaderIsInvalid() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/v1/auth/login");
        request.setServletPath("/api/v1/auth/login");
        request.addHeader("Authorization", "Bearer stale-client-token");
        MockHttpServletResponse response = new MockHttpServletResponse();
        AtomicReference<Boolean> reachedControllerChain = new AtomicReference<>(false);

        filter.doFilter(request, response, (servletRequest, servletResponse) ->
                reachedControllerChain.set(true));

        assertTrue(reachedControllerChain.get());
        assertEquals(200, response.getStatus());
    }

    @Test
    void shouldReturnUnifiedUnauthorizedResponseForInvalidAccessToken() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/v1/users/me");
        request.addHeader("Authorization", "Bearer not-a-jwt");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (servletRequest, servletResponse) -> {
            throw new AssertionError("Invalid token must not reach the downstream chain");
        });

        JsonNode body = objectMapper.readTree(response.getContentAsString());
        assertEquals(401, response.getStatus());
        assertEquals(40103, body.get("code").asInt());
    }

    @Test
    void shouldRejectRefreshTokenInAuthorizationHeader() throws Exception {
        JwtTokenPair tokens = jwtTokenService.issueTokenPair(7L);
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/v1/users/me");
        request.addHeader("Authorization", "Bearer " + tokens.refreshToken().value());
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (servletRequest, servletResponse) -> {
            throw new AssertionError("Refresh token must not authenticate an API request");
        });

        JsonNode body = objectMapper.readTree(response.getContentAsString());
        assertEquals(401, response.getStatus());
        assertEquals(40103, body.get("code").asInt());
    }

    @Test
    void shouldWriteUnifiedResponseWhenAuthenticationIsMissing() throws Exception {
        MockHttpServletResponse response = new MockHttpServletResponse();

        authenticationEntryPoint.commence(
                new MockHttpServletRequest("GET", "/api/v1/users/me"),
                response,
                null);

        JsonNode body = objectMapper.readTree(response.getContentAsString());
        assertEquals(401, response.getStatus());
        assertEquals(40100, body.get("code").asInt());
    }
}
