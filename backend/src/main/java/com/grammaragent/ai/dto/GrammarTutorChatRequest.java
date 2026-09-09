package com.grammaragent.ai.dto;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;
import java.util.List;

public record GrammarTutorChatRequest(
        @Positive Long grammarPointId,
        @NotBlank @Size(max = 2000) String message,
        @Size(max = 100) @Pattern(regexp = "\\S+") String questionCode,
        @Size(max = 8) List<@NotNull @Valid TutorMessage> history,
        @Positive Long lessonAttemptId
) {
    public GrammarTutorChatRequest {
        history = history == null ? List.of() : List.copyOf(history);
    }

    public GrammarTutorChatRequest(Long grammarPointId, String message, String questionCode, List<TutorMessage> history) {
        this(grammarPointId, message, questionCode, history, null);
    }

    @com.fasterxml.jackson.annotation.JsonIgnore
    @jakarta.validation.constraints.AssertTrue(message = "Provide a grammar point or a lesson attempt, exclusively")
    public boolean isContextValid() {
        return lessonAttemptId != null ? grammarPointId == null && questionCode == null : grammarPointId != null;
    }

    // Explicitly reject extra fields even when global Jackson ignores unknown properties.
    @JsonAnySetter
    public void rejectUnknown(String name, Object value) {
        throw new IllegalArgumentException("Unsupported tutor request field");
    }
}
