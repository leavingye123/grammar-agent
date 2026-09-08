package com.grammaragent.content;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.evaluator.QuestionAnswerEvaluator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

class ExistingQuestionRegressionTest {

    @Test
    void allCandidateCorrectAnswersMatchTheProductionEvaluator() {
        var content = new CurriculumContentLoader(new ObjectMapper()).loadEnglishA1();
        var evaluator = new QuestionAnswerEvaluator();
        content.chapters().stream()
                .flatMap(chapter -> chapter.grammarPoints().stream())
                .flatMap(point -> point.lessons().stream())
                .flatMap(lesson -> lesson.questions().stream())
                .forEach(source -> {
                    Question question = new Question();
                    question.setQuestionCode(source.questionCode());
                    question.setQuestionType(source.questionType());
                    question.setCorrectAnswer(source.correctAnswer());
                    JsonNode submitted = switch (source.questionType()) {
                        case FILL_BLANK -> source.correctAnswer().path("answers").get(0);
                        case CORRECTION -> source.correctAnswer().path("acceptedAnswers").get(0);
                        default -> source.correctAnswer();
                    };
                    assertTrue(
                            evaluator.evaluate(question, submitted).correct(),
                            source.questionCode());
                });
    }
}

