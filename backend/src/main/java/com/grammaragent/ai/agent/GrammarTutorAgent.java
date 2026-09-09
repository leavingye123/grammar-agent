package com.grammaragent.ai.agent;

import com.grammaragent.ai.context.GrammarContextBuilder;
import com.grammaragent.ai.dto.GrammarTutorChatRequest;
import com.grammaragent.ai.dto.GrammarTutorChatResponse;
import com.grammaragent.ai.dto.SuggestedQuestion;
import com.grammaragent.ai.llm.LLMGateway;
import com.grammaragent.ai.prompt.GrammarPromptManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
@RequiredArgsConstructor
public class GrammarTutorAgent {
    private final GrammarContextBuilder contextBuilder;
    private final GrammarPromptManager promptManager;
    private final LLMGateway gateway;

    public GrammarTutorChatResponse chat(Long userId, GrammarTutorChatRequest request) {
        var context = request.lessonAttemptId() == null
                ? contextBuilder.build(userId, request.grammarPointId(), request.questionCode())
                : contextBuilder.buildResult(userId, request.lessonAttemptId());
        String answer = gateway.chat(promptManager.build(context, request));
        return new GrammarTutorChatResponse(answer, suggestedQuestions(
                context.lessonResult() != null ? resultScene(context.lessonResult().wrongCount())
                        : context.submittedQuestion() == null ? "teaching"
                        : Boolean.FALSE.equals(context.submittedQuestion().deterministicCorrect()) ? "wrong" : "answered"));
    }

    public List<SuggestedQuestion> resultSuggestions(Long userId, Long attemptId) {
        var context = contextBuilder.buildResult(userId, attemptId);
        return suggestedQuestions(resultScene(context.lessonResult().wrongCount()));
    }

    private String resultScene(int wrongCount) {
        return wrongCount == 0 ? "result_perfect" : "result";
    }

    public List<SuggestedQuestion> suggestedQuestions(String scene) {
        List<String> questions = switch (scene) {
            case "result" -> List.of("我这次主要错在哪里？", "这个知识点怎么记？", "能再解释一下我错的题吗？", "接下来应该注意什么？");
            case "result_perfect" -> List.of("帮我总结这次用到的规则", "这个知识点怎么记？", "再给我一个简单例子", "接下来应该注意什么？");
            case "wrong" -> List.of("为什么我的答案错了？", "为什么正确答案是这个？", "能换一种方式解释吗？", "再给我一个类似例子。");
            case "answered" -> List.of("为什么这里这样用？", "能换一种方式解释吗？", "再给我一个类似例子。", "这个知识点最容易错在哪里？");
            default -> List.of("为什么要这样用？", "能再简单解释一下吗？", "能再给我两个例子吗？", "这个知识点最容易错在哪里？");
        };
        return questions.stream().map(SuggestedQuestion::new).toList();
    }
}
