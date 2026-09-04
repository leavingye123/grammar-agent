package com.grammaragent.common.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    SUCCESS(0, "success"),
    VALIDATION_ERROR(40000, "Request validation failed"),
    BUSINESS_ERROR(40001, "Business operation failed"),
    UNAUTHORIZED(40100, "Authentication is required"),
    INTERNAL_SERVER_ERROR(50000, "Internal server error");

    private final int code;
    private final String message;
}
