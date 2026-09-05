package com.grammaragent.auth.service;

import com.grammaragent.auth.dto.AuthResponse;
import com.grammaragent.auth.dto.LoginRequest;
import com.grammaragent.auth.dto.RegisterRequest;
import com.grammaragent.auth.dto.TokenResponse;
import com.grammaragent.auth.jwt.JwtProperties;
import com.grammaragent.auth.jwt.JwtTokenPair;
import com.grammaragent.auth.jwt.JwtTokenService;
import com.grammaragent.auth.jwt.ParsedJwt;
import com.grammaragent.auth.session.RefreshSessionStore;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.user.entity.User;
import com.grammaragent.user.enums.UserStatus;
import com.grammaragent.user.mapper.UserProfileMapper;
import com.grammaragent.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileMapper userProfileMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final JwtProperties jwtProperties;
    private final RefreshSessionStore refreshSessionStore;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = normalizeEmail(request.email());
        if (userRepository.findByEmailIgnoreCase(email).isPresent()) {
            throw new BusinessException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }

        User user = new User();
        user.setEmail(email);
        user.setUsername(request.username().trim());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setStatus(UserStatus.ACTIVE);

        try {
            userRepository.insert(user);
        } catch (DuplicateKeyException exception) {
            throw new BusinessException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }

        return new AuthResponse(userProfileMapper.toProfileResponse(user), issueTokens(user));
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmailIgnoreCase(normalizeEmail(request.email()))
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_CREDENTIALS));

        ensureActive(user);
        if (user.getPasswordHash() == null
                || !passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
        }

        user.setLastLoginAt(OffsetDateTime.now(ZoneOffset.UTC));
        userRepository.update(user);
        return new AuthResponse(userProfileMapper.toProfileResponse(user), issueTokens(user));
    }

    public TokenResponse refresh(String refreshToken) {
        ParsedJwt parsedToken = jwtTokenService.parseRefreshToken(refreshToken);
        Long sessionUserId = refreshSessionStore.consume(parsedToken.tokenId())
                .orElseThrow(() -> new BusinessException(ErrorCode.REFRESH_TOKEN_REVOKED));
        if (!sessionUserId.equals(parsedToken.userId())) {
            throw new BusinessException(ErrorCode.REFRESH_TOKEN_INVALID);
        }

        User user = userRepository.findById(parsedToken.userId())
                .orElseThrow(() -> new BusinessException(ErrorCode.REFRESH_TOKEN_INVALID));
        ensureActive(user);
        return issueTokens(user);
    }

    public void logout(Long authenticatedUserId, String refreshToken) {
        ParsedJwt parsedToken = jwtTokenService.parseRefreshToken(refreshToken);
        if (!authenticatedUserId.equals(parsedToken.userId())) {
            throw new BusinessException(ErrorCode.REFRESH_TOKEN_INVALID);
        }
        refreshSessionStore.revoke(parsedToken.tokenId());
    }

    private TokenResponse issueTokens(User user) {
        JwtTokenPair tokenPair = jwtTokenService.issueTokenPair(user.getId());
        refreshSessionStore.save(
                tokenPair.refreshToken().tokenId(),
                user.getId(),
                tokenPair.refreshToken().expiresAt());
        return TokenResponse.from(tokenPair, jwtProperties);
    }

    private void ensureActive(User user) {
        if (user.getStatus() == UserStatus.DISABLED) {
            throw new BusinessException(ErrorCode.USER_DISABLED);
        }
        if (user.getStatus() == UserStatus.LOCKED) {
            throw new BusinessException(ErrorCode.USER_LOCKED);
        }
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
