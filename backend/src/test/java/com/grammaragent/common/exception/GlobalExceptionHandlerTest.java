package com.grammaragent.common.exception;

import com.grammaragent.common.enums.ErrorCode;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static org.assertj.core.api.Assertions.assertThat;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void shouldReturnBusinessError() {
        BusinessException exception = new BusinessException("Course is unavailable");

        var response = handler.handleBusinessException(exception);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo(ErrorCode.BUSINESS_ERROR.getCode());
        assertThat(response.getBody().message()).isEqualTo("Course is unavailable");
    }

    @Test
    void shouldHideUnexpectedExceptionDetails() {
        var response = handler.handleUnexpectedException(new IllegalStateException("sensitive detail"));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo(ErrorCode.INTERNAL_SERVER_ERROR.getCode());
        assertThat(response.getBody().message()).isEqualTo("Internal server error");
    }
}
