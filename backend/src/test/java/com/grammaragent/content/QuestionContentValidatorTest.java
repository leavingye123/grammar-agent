package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.content.model.CurriculumContent;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class QuestionContentValidatorTest {

    private final CurriculumContentLoader loader = new CurriculumContentLoader(new ObjectMapper());

    @Test
    void candidateBankPassesDeterministicStructureAndQualityChecks() {
        var report = new QuestionContentValidator().inspect(loader.loadEnglishA1());

        assertEquals(128, report.questionCount());
        assertTrue(report.errors().isEmpty(), () -> String.join("\n", report.errors()));
        assertTrue(report.warnings().isEmpty(), () -> String.join("\n", report.warnings()));
        assertEquals(0, report.exactDuplicateCount());
        assertEquals(0, report.normalizedDuplicateCount());
        assertEquals(0, report.mechanicalNameVariantCount());
        assertEquals(0, report.explanationMissingCount());
        assertEquals(128, report.aiDraftCount());
        assertEquals(128, report.reviewRequiredCount());
        assertEquals(0, report.approvedCount());
        assertEquals(0, report.validatorErrorCount());
        assertEquals(0, report.validatorWarningCount());
        assertEquals(13, report.microLessonCount());
        assertEquals(26, report.quickCheckCount());
        assertEquals(39, report.readyLessonCount());
        assertEquals(96, report.comingSoonLessonCount());
    }

    @Test
    void aiDraftCannotBypassEditorialReviewByBeingMarkedApproved() throws Exception {
        var objectMapper = new ObjectMapper();
        var resource = new ClassPathResource(CurriculumContentLoader.ENGLISH_A1_RESOURCE);
        com.fasterxml.jackson.databind.JsonNode root;
        try (var input = resource.getInputStream()) {
            root = objectMapper.readTree(input);
        }
        ((com.fasterxml.jackson.databind.node.ObjectNode) root.path("chapters").get(0)
                .path("grammarPoints").get(0)
                .path("lessons").get(0)
                .path("questions").get(0))
                .put("reviewStatus", "APPROVED");
        var content = objectMapper.treeToValue(root, CurriculumContent.class);

        var validator = new QuestionContentValidator();
        var report = validator.inspect(content);

        assertTrue(report.errors().stream().anyMatch(error -> error.contains("AI_DRAFT")));
        assertThrows(IllegalStateException.class, () -> validator.validate(content));
    }
}
