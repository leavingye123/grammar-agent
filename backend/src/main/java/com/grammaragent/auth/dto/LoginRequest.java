package com.grammaragent.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @NotBlank
        @Email
        @Size(max = 320)
        @Schema(example = "test@example.com")
        String email,

        @NotBlank
        @Size(max = 72)
        @Schema(example = "Password123!")
        String password
) {
}
