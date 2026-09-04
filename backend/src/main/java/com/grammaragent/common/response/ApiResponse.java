package com.grammaragent.common.response;

import com.grammaragent.common.enums.ErrorCode;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.Instant;

@Schema(description = "Unified API response")
public record ApiResponse<T>(
        @Schema(description = "Business response code", example = "0") int code,
        @Schema(description = "Human-readable response message", example = "success") String message,
        @Schema(description = "Response payload") T data,
        @Schema(description = "Response generation time in UTC") Instant timestamp
) {

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMessage(), data, Instant.now());
    }

    public static <T> ApiResponse<T> error(ErrorCode errorCode) {
        return error(errorCode, errorCode.getMessage(), null);
    }

    public static <T> ApiResponse<T> error(ErrorCode errorCode, String message, T data) {
        return new ApiResponse<>(errorCode.getCode(), message, data, Instant.now());
    }
}
