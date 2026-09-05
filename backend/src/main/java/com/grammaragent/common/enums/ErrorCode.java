package com.grammaragent.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    SUCCESS(0, "success", HttpStatus.OK),
    VALIDATION_ERROR(40000, "Request validation failed", HttpStatus.BAD_REQUEST),
    BUSINESS_ERROR(40001, "Business operation failed", HttpStatus.BAD_REQUEST),
    EMAIL_ALREADY_EXISTS(40901, "Email is already registered", HttpStatus.CONFLICT),
    INVALID_CREDENTIALS(40101, "Invalid email or password", HttpStatus.UNAUTHORIZED),
    ACCESS_TOKEN_EXPIRED(40102, "Access token has expired", HttpStatus.UNAUTHORIZED),
    ACCESS_TOKEN_INVALID(40103, "Access token is invalid", HttpStatus.UNAUTHORIZED),
    REFRESH_TOKEN_EXPIRED(40104, "Refresh token has expired", HttpStatus.UNAUTHORIZED),
    REFRESH_TOKEN_INVALID(40105, "Refresh token is invalid", HttpStatus.UNAUTHORIZED),
    REFRESH_TOKEN_REVOKED(40106, "Refresh token has been revoked", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED(40100, "Authentication is required", HttpStatus.UNAUTHORIZED),
    FORBIDDEN(40300, "Access is forbidden", HttpStatus.FORBIDDEN),
    USER_DISABLED(40301, "User account is disabled", HttpStatus.FORBIDDEN),
    USER_LOCKED(40302, "User account is locked", HttpStatus.FORBIDDEN),
    USER_NOT_FOUND(40401, "User does not exist", HttpStatus.NOT_FOUND),
    LANGUAGE_NOT_FOUND(40410, "Language not found", HttpStatus.NOT_FOUND),
    LEVEL_NOT_FOUND(40411, "Language level not found", HttpStatus.NOT_FOUND),
    CHAPTER_NOT_FOUND(40412, "Chapter not found", HttpStatus.NOT_FOUND),
    GRAMMAR_POINT_NOT_FOUND(40413, "Grammar point not found", HttpStatus.NOT_FOUND),
    LESSON_NOT_FOUND(40414, "Lesson not found", HttpStatus.NOT_FOUND),
    INTERNAL_SERVER_ERROR(50000, "Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;
    private final String message;
    private final HttpStatus httpStatus;
}
