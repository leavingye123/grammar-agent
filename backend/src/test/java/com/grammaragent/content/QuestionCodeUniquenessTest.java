package com.grammaragent.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.util.HashSet;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class QuestionCodeUniquenessTest {

    @Test
    void everyCandidateQuestionHasAUniqueStableCode() {
        var content = new CurriculumContentLoader(new ObjectMapper()).loadEnglishA1();
        var questions = content.chapters().stream()
                .flatMap(chapter -> chapter.grammarPoints().stream())
                .flatMap(point -> point.lessons().stream())
                .flatMap(lesson -> lesson.questions().stream())
                .toList();
        var codes = new HashSet<String>();
        questions.forEach(question -> assertTrue(codes.add(question.questionCode()), question.questionCode()));
        assertEquals(questions.size(), codes.size());
    }
}

