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
    INVALID_ANSWER_FORMAT(40010, "Answer format is invalid for this question type", HttpStatus.BAD_REQUEST),
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
    QUESTION_NOT_FOUND(40415, "Question not found", HttpStatus.NOT_FOUND),
    REVIEW_ITEM_NOT_FOUND(40420, "Question is not in the user's review list", HttpStatus.NOT_FOUND),
    LESSON_ANSWERS_INCOMPLETE(40910, "Not all lesson questions have been answered", HttpStatus.CONFLICT),
    LESSON_HAS_NO_QUESTIONS(40911, "Lesson has no enabled questions", HttpStatus.CONFLICT),
    QUESTION_CONTEXT_INVALID(40912, "Question content relationship is invalid", HttpStatus.CONFLICT),
    REVIEW_ITEM_ALREADY_MASTERED(40920, "Review item is already mastered", HttpStatus.CONFLICT),
    AI_TUTOR_UNAVAILABLE(50310, "AI Tutor is not configured or temporarily unavailable", HttpStatus.SERVICE_UNAVAILABLE),
    AI_TUTOR_TIMEOUT(50410, "AI Tutor timed out; please try again", HttpStatus.GATEWAY_TIMEOUT),
    AI_TUTOR_RATE_LIMITED(42910, "AI Tutor is busy; please try again later", HttpStatus.TOO_MANY_REQUESTS),
    AI_TUTOR_PROVIDER_ERROR(50210, "AI Tutor is temporarily unavailable", HttpStatus.BAD_GATEWAY),
    AI_TUTOR_ANSWER_REQUIRED(40310, "Submit this question before asking for an explanation", HttpStatus.FORBIDDEN),
    AI_TUTOR_COMPLETED_ATTEMPT_REQUIRED(40311, "A completed lesson attempt belonging to you is required", HttpStatus.FORBIDDEN),
    INTERNAL_SERVER_ERROR(50000, "Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;
    private final String message;
    private final HttpStatus httpStatus;
}
