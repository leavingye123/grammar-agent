package com.grammaragent.ai.dto;

import java.util.List;

public record GrammarTutorChatResponse(String answer, List<SuggestedQuestion> suggestedQuestions) {}
