package com.grammaragent.ai.context;

import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Set;

@Component
public class GrammarScopePolicy {
    private static final Set<String> GOLD_CODES = Set.of("A1-009", "A1-012", "A1-016", "A1-019", "A1-020");

    public String forPoint(String code) {
        if (!GOLD_CODES.contains(code)) {
            return "In Scope: current Learning Objective, Core Rules and Pattern only. "
                    + "Not Yet: additional rules, exceptions or prerequisite-heavy topics absent from this lesson; "
                    + "briefly defer them instead of inventing an expanded syllabus.";
        }
        var resource = new ClassPathResource("ai/gold-standard/" + code + ".md");
        try (var input = resource.getInputStream()) {
            String document = new String(input.readAllBytes(), StandardCharsets.UTF_8);
            int start = document.indexOf("## 3. Core rules, scope, and Not Yet");
            int end = start < 0 ? -1 : document.indexOf("\n## 4.", start);
            if (start < 0 || end < 0) throw new IOException("Missing scope section");
            // No examples audit / question bank sections may enter the context.
            return document.substring(start, end).trim();
        } catch (IOException exception) {
            // An unavailable authoritative boundary must not silently widen the scope.
            throw new BusinessException(ErrorCode.AI_TUTOR_UNAVAILABLE);
        }
    }
}
