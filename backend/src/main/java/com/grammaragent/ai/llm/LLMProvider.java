package com.grammaragent.ai.llm;

import java.util.List;

/** Vendor-neutral, synchronous completion contract; no grading or tool execution. */
public interface LLMProvider {
    String chat(ChatRequest request);

    record Message(String role, String content) {}
    record ChatRequest(List<Message> messages) {
        public ChatRequest { messages = List.copyOf(messages); }
    }
}
