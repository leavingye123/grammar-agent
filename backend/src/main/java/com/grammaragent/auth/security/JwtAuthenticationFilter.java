package com.grammaragent.auth.security;

import com.grammaragent.auth.jwt.JwtTokenService;
import com.grammaragent.auth.jwt.ParsedJwt;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final PathPatternRequestMatcher.Builder PATHS = PathPatternRequestMatcher.withDefaults();
    private static final List<RequestMatcher> PUBLIC_ENDPOINTS = List.of(
            PATHS.matcher(HttpMethod.GET, "/api/v1/health"),
            PATHS.matcher(HttpMethod.POST, "/api/v1/auth/register"),
            PATHS.matcher(HttpMethod.POST, "/api/v1/auth/login"),
            PATHS.matcher(HttpMethod.POST, "/api/v1/auth/refresh"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/languages"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/languages/**"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/levels/**"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/chapters/**"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/grammar-points/**"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/lessons/**"),
            PATHS.matcher(HttpMethod.GET, "/api/v1/learning-path/**"),
            PATHS.matcher(HttpMethod.GET, "/v3/api-docs/**"),
            PATHS.matcher(HttpMethod.GET, "/swagger-ui.html"),
            PATHS.matcher(HttpMethod.GET, "/swagger-ui/**"));

    private final JwtTokenService jwtTokenService;
    private final SecurityErrorResponseWriter errorResponseWriter;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return PUBLIC_ENDPOINTS.stream().anyMatch(matcher -> matcher.matches(request));
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        String authorization = request.getHeader("Authorization");
        if (authorization == null) {
            filterChain.doFilter(request, response);
            return;
        }

        if (!authorization.startsWith(BEARER_PREFIX)
                || authorization.substring(BEARER_PREFIX.length()).isBlank()) {
            errorResponseWriter.write(response, ErrorCode.ACCESS_TOKEN_INVALID);
            return;
        }

        try {
            String token = authorization.substring(BEARER_PREFIX.length()).trim();
            ParsedJwt parsedJwt = jwtTokenService.parseAccessToken(token);
            AuthenticatedUserPrincipal principal = new AuthenticatedUserPrincipal(parsedJwt.userId());
            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(principal, null, List.of());
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authentication);
            filterChain.doFilter(request, response);
        } catch (BusinessException exception) {
            SecurityContextHolder.clearContext();
            errorResponseWriter.write(response, exception.getErrorCode());
        }
    }
}
