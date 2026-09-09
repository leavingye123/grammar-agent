package com.grammaragent.ai.llm;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;

public class DisabledLLMProvider implements LLMProvider {
    @Override
    public String chat(ChatRequest request) {
        throw new BusinessException(ErrorCode.AI_TUTOR_UNAVAILABLE);
    }
}
