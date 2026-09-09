package com.grammaragent.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.ai.agent.GrammarTutorAgent;
import com.grammaragent.ai.config.AiTutorConfig;
import com.grammaragent.ai.config.AiTutorProperties;
import com.grammaragent.ai.dto.GrammarTutorChatRequest;
import com.grammaragent.ai.llm.DisabledLLMProvider;
import com.grammaragent.ai.llm.LLMProvider;
import com.grammaragent.ai.service.GrammarTutorService;
import com.grammaragent.common.HealthService;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.evaluator.QuestionAnswerEvaluator;
import jakarta.validation.Validation;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AiTutorConfigTest {
    @Test void disabledOrMissingKeyDoesNotBreakOtherBeansOrGrading() {
        for (boolean enabled : List.of(false, true)) {
            new ApplicationContextRunner().withUserConfiguration(AiTutorConfig.class, HealthService.class,
                            QuestionAnswerEvaluator.class)
                    .withPropertyValues("app.ai-tutor.enabled=" + enabled, "app.ai-tutor.base-url=https://example.invalid/v1",
                            "app.ai-tutor.model=test-model")
                    .run(context -> {
                        assertNull(context.getStartupFailure());
                        var provider = context.getBean(LLMProvider.class);
                        assertInstanceOf(DisabledLLMProvider.class, provider);
                        assertEquals(ErrorCode.AI_TUTOR_UNAVAILABLE, assertThrows(BusinessException.class,
                                () -> provider.chat(new LLMProvider.ChatRequest(List.of()))).getErrorCode());
                        assertEquals("UP", context.getBean(HealthService.class).getHealth().status());
                        var question = new Question();
                        question.setQuestionType(QuestionType.FILL_BLANK);
                        question.setCorrectAnswer(new ObjectMapper().readTree("{\"answers\":[\"an\"]}"));
                        assertTrue(context.getBean(QuestionAnswerEvaluator.class)
                                .evaluate(question, new ObjectMapper().readTree("\"an\"")).correct());
                    });
        }
    }

    @Test void disabledServiceDoesNotReadCourseOrCallAgent() {
        var agent = mock(GrammarTutorAgent.class);
        try (var factory = Validation.buildDefaultValidatorFactory()) {
            var service = new GrammarTutorService(agent, new AiTutorProperties(), factory.getValidator());
            assertEquals(ErrorCode.AI_TUTOR_UNAVAILABLE, assertThrows(BusinessException.class,
                    () -> service.chat(7L, new GrammarTutorChatRequest(16L, "why", null, List.of()))).getErrorCode());
            verifyNoInteractions(agent);
        }
    }

    @Test void invalidConfigurationFailsClosedAndReplacementProviderCanBeInjected() {
        var properties = new AiTutorProperties();
        properties.setEnabled(true);
        properties.setBaseUrl("not-a-url");
        properties.setApiKey("test-only-placeholder");
        properties.setModel("fake");
        assertFalse(properties.isConfigured());
        new ApplicationContextRunner().withUserConfiguration(AiTutorConfig.class)
                .withBean(LLMProvider.class, () -> request -> "local fake")
                .run(context -> assertEquals("local fake", context.getBean(LLMProvider.class)
                        .chat(new LLMProvider.ChatRequest(List.of()))));
    }
}
