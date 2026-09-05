package com.grammaragent.user.dto;

import com.grammaragent.user.enums.UserStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.OffsetDateTime;

@Schema(description = "Public profile of the authenticated user")
public record UserProfileResponse(
        Long id,
        String email,
        String username,
        String avatarUrl,
        String nativeLanguage,
        UserStatus status,
        OffsetDateTime createdAt
) {
}
