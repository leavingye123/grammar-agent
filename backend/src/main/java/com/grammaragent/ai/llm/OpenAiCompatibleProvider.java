package com.grammaragent.ai.llm;

import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.ai.config.AiTutorProperties;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import java.net.SocketTimeoutException;
import java.net.http.HttpTimeoutException;
import java.util.Map;

@RequiredArgsConstructor
public class OpenAiCompatibleProvider implements LLMProvider {
    private final RestClient client;
    private final AiTutorProperties properties;

    @Override
    public String chat(ChatRequest request) {
        try {
            JsonNode body = client.post()
                    .uri(properties.getBaseUrl().replaceAll("/+$", "") + "/chat/completions")
                    .headers(headers -> headers.setBearerAuth(properties.getApiKey()))
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of("model", properties.getModel(), "messages", request.messages(),
                            "temperature", properties.getTemperature(), "max_tokens", properties.getMaxTokens(),
                            "stream", false))
                    .retrieve().body(JsonNode.class);
            JsonNode answer = body == null ? null : body.path("choices").path(0).path("message").path("content");
            if (answer == null || !answer.isTextual() || answer.asText().isBlank()
                    || answer.asText().length() > 12000) {
                throw new BusinessException(ErrorCode.AI_TUTOR_PROVIDER_ERROR);
            }
            return answer.asText().trim();
        } catch (BusinessException exception) {
            throw exception;
        } catch (RestClientResponseException exception) {
            throw new BusinessException(switch (exception.getStatusCode().value()) {
                case 401, 403 -> ErrorCode.AI_TUTOR_UNAVAILABLE;
                case 429 -> ErrorCode.AI_TUTOR_RATE_LIMITED;
                case 408, 504 -> ErrorCode.AI_TUTOR_TIMEOUT;
                default -> ErrorCode.AI_TUTOR_PROVIDER_ERROR;
            });
        } catch (ResourceAccessException exception) {
            Throwable cause = exception;
            while (cause != null) {
                if (cause instanceof SocketTimeoutException || cause instanceof HttpTimeoutException
                        || cause instanceof java.util.concurrent.TimeoutException) {
                    throw new BusinessException(ErrorCode.AI_TUTOR_TIMEOUT);
                }
                cause = cause.getCause();
            }
            throw new BusinessException(ErrorCode.AI_TUTOR_PROVIDER_ERROR);
        } catch (RuntimeException exception) {
            throw new BusinessException(ErrorCode.AI_TUTOR_PROVIDER_ERROR);
        }
    }
}
