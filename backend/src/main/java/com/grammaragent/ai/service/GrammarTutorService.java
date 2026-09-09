package com.grammaragent.ai.service;

import com.grammaragent.ai.agent.GrammarTutorAgent;
import com.grammaragent.ai.config.AiTutorProperties;
import com.grammaragent.ai.dto.GrammarTutorChatRequest;
import com.grammaragent.ai.dto.GrammarTutorChatResponse;
import com.grammaragent.ai.dto.SuggestedQuestion;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import jakarta.validation.Validator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GrammarTutorService {
    private final GrammarTutorAgent agent;
    private final AiTutorProperties properties;
    private final Validator validator;

    public GrammarTutorChatResponse chat(Long userId, GrammarTutorChatRequest request) {
        if (userId == null) throw new BusinessException(ErrorCode.UNAUTHORIZED);
        if (!validator.validate(request).isEmpty()) throw new BusinessException(ErrorCode.VALIDATION_ERROR);
        if (!properties.isConfigured()) throw new BusinessException(ErrorCode.AI_TUTOR_UNAVAILABLE);
        return agent.chat(userId, request);
    }

    public TutorStatus status(String scene) {
        return new TutorStatus(properties.isConfigured(), agent.suggestedQuestions(scene));
    }

    public TutorStatus resultStatus(Long userId, Long attemptId) {
        if (userId == null) throw new BusinessException(ErrorCode.UNAUTHORIZED);
        if (attemptId == null || attemptId <= 0) throw new BusinessException(ErrorCode.VALIDATION_ERROR);
        if (!properties.isConfigured()) return new TutorStatus(false, List.of());
        return new TutorStatus(true, agent.resultSuggestions(userId, attemptId));
    }

    public record TutorStatus(boolean available, List<SuggestedQuestion> suggestedQuestions) {}
}
