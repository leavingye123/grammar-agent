package com.grammaragent.ai;

import com.grammaragent.ai.config.AiTutorProperties;
import com.grammaragent.ai.llm.LLMGateway;
import com.grammaragent.ai.llm.LLMProvider;
import com.grammaragent.ai.llm.OpenAiCompatibleProvider;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;
import java.net.SocketTimeoutException;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

class OpenAiCompatibleProviderTest {
    final RestClient.Builder client = RestClient.builder();
    final MockRestServiceServer server = MockRestServiceServer.bindTo(client).build();
    final LLMProvider.ChatRequest request = new LLMProvider.ChatRequest(
            List.of(new LLMProvider.Message("user", "why")));

    OpenAiCompatibleProvider provider() {
        var properties = new AiTutorProperties();
        properties.setBaseUrl("https://example.invalid/v1/");
        properties.setApiKey("test-only-placeholder");
        properties.setModel("fake-model");
        return new OpenAiCompatibleProvider(client.build(), properties);
    }

    @Test void sendsCompatibleRequestAndDecodesText() {
        server.expect(requestTo("https://example.invalid/v1/chat/completions"))
                .andExpect(header("Authorization", "Bearer test-only-placeholder"))
                .andExpect(jsonPath("$.model").value("fake-model"))
                .andExpect(jsonPath("$.stream").value(false))
                .andExpect(jsonPath("$.messages[0].content").value("why"))
                .andRespond(withSuccess("{\"choices\":[{\"message\":{\"content\":\"Because...\"}}]}", MediaType.APPLICATION_JSON));
        assertEquals("Because...", provider().chat(request));
        server.verify();
    }

    @Test void mapsProviderHttpErrorsWithoutLeakingBodies() {
        for (HttpStatus status : List.of(HttpStatus.UNAUTHORIZED, HttpStatus.TOO_MANY_REQUESTS,
                HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.BAD_GATEWAY, HttpStatus.GATEWAY_TIMEOUT)) {
            server.reset();
            server.expect(requestTo("https://example.invalid/v1/chat/completions"))
                    .andRespond(withStatus(status).body("secret provider diagnostic test-only-placeholder"));
            var exception = assertThrows(BusinessException.class, () -> provider().chat(request));
            assertEquals(switch (status) {
                case UNAUTHORIZED -> ErrorCode.AI_TUTOR_UNAVAILABLE;
                case TOO_MANY_REQUESTS -> ErrorCode.AI_TUTOR_RATE_LIMITED;
                case GATEWAY_TIMEOUT -> ErrorCode.AI_TUTOR_TIMEOUT;
                default -> ErrorCode.AI_TUTOR_PROVIDER_ERROR;
            }, exception.getErrorCode());
            assertFalse(exception.getMessage().contains("secret"));
            assertNull(exception.getCause());
            server.verify();
        }
    }

    @Test void timeoutIsSafeBusinessError() {
        server.expect(requestTo("https://example.invalid/v1/chat/completions"))
                .andRespond(withException(new SocketTimeoutException("secret URL")));
        assertEquals(ErrorCode.AI_TUTOR_TIMEOUT,
                assertThrows(BusinessException.class, () -> provider().chat(request)).getErrorCode());
    }

    @Test void malformedMissingEmptyOrOversizedContentIsRejected() {
        for (String body : List.of("not json", "{}", "{\"choices\":[{\"message\":{\"content\":[]}}]}",
                "{\"choices\":[{\"message\":{\"content\":\" \"}}]}",
                "{\"choices\":[{\"message\":{\"content\":\"" + "x".repeat(12001) + "\"}}]}")) {
            server.reset();
            server.expect(requestTo("https://example.invalid/v1/chat/completions"))
                    .andRespond(withSuccess(body, MediaType.APPLICATION_JSON));
            assertEquals(ErrorCode.AI_TUTOR_PROVIDER_ERROR,
                    assertThrows(BusinessException.class, () -> provider().chat(request)).getErrorCode());
        }
    }

    @Test void gatewaySanitizesUnexpectedProviderExceptions() {
        var gateway = new LLMGateway(ignored -> { throw new IllegalStateException("sensitive provider payload"); });
        var exception = assertThrows(BusinessException.class, () -> gateway.chat(request));
        assertEquals(ErrorCode.AI_TUTOR_PROVIDER_ERROR, exception.getErrorCode());
        assertFalse(exception.getMessage().contains("sensitive"));
    }
}
