package com.grammaragent.auth.dto;

import com.grammaragent.user.dto.UserProfileResponse;

public record AuthResponse(UserProfileResponse user, TokenResponse tokens) {
}
