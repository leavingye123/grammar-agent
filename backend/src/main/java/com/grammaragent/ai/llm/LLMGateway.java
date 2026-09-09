package com.grammaragent.ai.llm;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import java.util.UUID;

@Slf4j
@Component
@RequiredArgsConstructor
public class LLMGateway {
    private final LLMProvider provider;

    public String chat(LLMProvider.ChatRequest request) {
        String requestId = UUID.randomUUID().toString();
        long started = System.nanoTime();
        boolean success = false;
        try {
            String answer = provider.chat(request);
            if (answer == null || answer.isBlank() || answer.length() > 12000) {
                throw new BusinessException(ErrorCode.AI_TUTOR_PROVIDER_ERROR);
            }
            success = true;
            return answer;
        } catch (BusinessException exception) {
            throw exception;
        } catch (RuntimeException exception) {
            // Never forward provider bodies, exception messages, credentials or prompts.
            throw new BusinessException(ErrorCode.AI_TUTOR_PROVIDER_ERROR);
        } finally {
            log.info("Tutor requestId={} latencyMs={} success={}", requestId,
                    (System.nanoTime() - started) / 1_000_000, success);
        }
    }
}
