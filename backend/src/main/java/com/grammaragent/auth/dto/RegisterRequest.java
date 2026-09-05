package com.grammaragent.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank
        @Email
        @Size(max = 320)
        @Schema(example = "test@example.com")
        String email,

        @NotBlank
        @Size(min = 2, max = 50)
        @Schema(example = "test-user")
        String username,

        @NotBlank
        @Size(min = 8, max = 72)
        @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d).+$",
                message = "password must contain at least one letter and one number")
        @Schema(example = "Password123!")
        String password
) {
}
