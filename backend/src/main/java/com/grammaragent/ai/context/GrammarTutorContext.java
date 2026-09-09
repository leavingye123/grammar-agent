package com.grammaragent.ai.context;

import com.fasterxml.jackson.databind.JsonNode;
import com.grammaragent.grammar.dto.PrerequisiteResponse;
import java.util.List;

public record GrammarTutorContext(GrammarPointContext grammarPoint, QuestionContext submittedQuestion,
                                  LessonResultContext lessonResult) {
    public GrammarTutorContext(GrammarPointContext grammarPoint, QuestionContext submittedQuestion) {
        this(grammarPoint, submittedQuestion, null);
    }

    public record LessonResultContext(
            Long lessonId, String lessonTitle, Long lessonAttemptId,
            java.time.OffsetDateTime completedAt, int score, int totalCount, int correctCount,
            int wrongCount, int xpEarned, List<QuestionContext> wrongQuestions
    ) {}
    public record GrammarPointContext(
            Long id, String code, String title, Integer difficulty, String description,
            String grammarRule, JsonNode examples, JsonNode commonErrors,
            JsonNode microLesson, List<PrerequisiteResponse> prerequisites, String scopeAndNotYet
    ) {}

    public record QuestionContext(
            String questionCode, String questionType, String questionContent, JsonNode options,
            JsonNode userAnswer, JsonNode correctAnswer, Boolean deterministicCorrect,
            String canonicalExplanation
    ) {}
}
