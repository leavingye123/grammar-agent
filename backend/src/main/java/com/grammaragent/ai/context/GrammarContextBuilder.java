package com.grammaragent.ai.context;

import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.grammar.service.GrammarCatalogService;
import com.grammaragent.learning.enums.LessonAttemptStatus;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.service.QuestionContextService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Objects;
import java.util.ArrayList;
import java.util.HashMap;

@Component
@RequiredArgsConstructor
public class GrammarContextBuilder {
    private final GrammarCatalogService grammarCatalog;
    private final QuestionRepository questions;
    private final UserAnswerRepository answers;
    private final QuestionContextService questionContext;
    private final GrammarScopePolicy scopePolicy;
    private final LessonAttemptRepository attempts;

    @Transactional(readOnly = true)
    public GrammarTutorContext buildResult(Long userId, Long attemptId) {
        if (userId == null) throw new BusinessException(ErrorCode.UNAUTHORIZED);
        var attempt = attempts.findByUserAndId(userId, attemptId)
                .filter(item -> Objects.equals(item.getUserId(), userId) && Objects.equals(item.getId(), attemptId)
                        && item.getStatus() == LessonAttemptStatus.COMPLETED
                        && item.getCompletedAt() != null)
                .orElseThrow(this::completedAttemptRequired);
        if (attempt.getTotalCount() == null || attempt.getTotalCount() < 1 || attempt.getTotalCount() > 50
                || attempt.getCorrectCount() == null || attempt.getCorrectCount() < 0
                || attempt.getCorrectCount() > attempt.getTotalCount()
                || attempt.getScore() == null || attempt.getXpEarned() == null) {
            throw completedAttemptRequired();
        }
        var lesson = questionContext.requireEnabledLesson(attempt.getLessonId());
        var lessonQuestions = questions.findEnabledByLessonId(lesson.getId());
        var latest = answers.findLatestByQuestionIdsInAttempt(userId,
                lessonQuestions.stream().map(Question::getId).toList(), attemptId);
        if (lessonQuestions.size() != attempt.getTotalCount() || latest.size() != attempt.getTotalCount()) {
            throw completedAttemptRequired();
        }
        var byQuestion = new HashMap<Long, UserAnswer>();
        for (var answer : latest) {
            if (!Objects.equals(answer.getUserId(), userId) || !Objects.equals(answer.getLessonAttemptId(), attemptId)
                    || answer.getIsCorrect() == null || answer.getAnswer() == null || answer.getAnswer().isNull()
                    || answer.getAnsweredAt() == null || answer.getAnsweredAt().isAfter(attempt.getCompletedAt())
                    || byQuestion.put(answer.getQuestionId(), answer) != null) {
                throw completedAttemptRequired();
            }
        }
        var wrong = new ArrayList<GrammarTutorContext.QuestionContext>();
        for (var question : lessonQuestions) {
            questionContext.validateQuestion(question, lesson);
            var answer = byQuestion.get(question.getId());
            if (answer == null) throw completedAttemptRequired();
            if (!answer.getIsCorrect()) {
                if (question.getCorrectAnswer() == null || question.getCorrectAnswer().isNull()) {
                    throw completedAttemptRequired();
                }
                wrong.add(new GrammarTutorContext.QuestionContext(question.getQuestionCode(),
                        question.getQuestionType().name(), question.getQuestionContent(), question.getOptions(),
                        answer.getAnswer(), question.getCorrectAnswer(), false, question.getExplanation()));
            }
        }
        // Integrity check only: no score/XP recalculation and no evaluation of answer content.
        if (wrong.size() != attempt.getTotalCount() - attempt.getCorrectCount()) throw completedAttemptRequired();
        var grammar = build(userId, lesson.getGrammarPointId(), null).grammarPoint();
        return new GrammarTutorContext(grammar, null, new GrammarTutorContext.LessonResultContext(
                lesson.getId(), lesson.getTitle(), attemptId, attempt.getCompletedAt(), attempt.getScore(),
                attempt.getTotalCount(), attempt.getCorrectCount(), wrong.size(), attempt.getXpEarned(), List.copyOf(wrong)));
    }

    private BusinessException completedAttemptRequired() {
        return new BusinessException(ErrorCode.AI_TUTOR_COMPLETED_ATTEMPT_REQUIRED);
    }

    @Transactional(readOnly = true)
    public GrammarTutorContext build(Long userId, Long grammarPointId, String questionCode) {
        if (userId == null) throw new BusinessException(ErrorCode.UNAUTHORIZED);
        var point = grammarCatalog.getGrammarPoint(grammarPointId);
        ObjectNode micro = JsonNodeFactory.instance.objectNode();
        if (point.microLesson() != null) {
            // Teaching context excludes Quick Check answer keys and any future non-teaching fields.
            for (String field : List.of("learningObjective", "shortIntroduction", "coreRule", "structure",
                    "examples", "commonMistakes", "memoryTip", "inScope", "notYet")) {
                if (point.microLesson().has(field)) micro.set(field, point.microLesson().get(field));
            }
        }
        var grammar = new GrammarTutorContext.GrammarPointContext(point.id(), point.code(), point.title(),
                point.difficulty(), point.description(), point.grammarRule(), point.examples(), point.commonErrors(),
                micro, point.prerequisites(), scopePolicy.forPoint(point.code()));
        if (questionCode == null) return new GrammarTutorContext(grammar, null);

        var question = questions.findEnabledByCode(questionCode)
                .orElseThrow(() -> new BusinessException(ErrorCode.AI_TUTOR_ANSWER_REQUIRED));
        if (!Objects.equals(question.getGrammarPointId(), grammarPointId)) {
            throw new BusinessException(ErrorCode.AI_TUTOR_ANSWER_REQUIRED);
        }
        var submitted = answers.findLatestByUserAndQuestion(userId, question.getId())
                .filter(answer -> Objects.equals(answer.getUserId(), userId)
                        && Objects.equals(answer.getQuestionId(), question.getId())
                        && answer.getAnswer() != null && answer.getIsCorrect() != null)
                .orElseThrow(() -> new BusinessException(ErrorCode.AI_TUTOR_ANSWER_REQUIRED));
        var lesson = questionContext.requireEnabledLesson(question.getLessonId());
        questionContext.validateQuestion(question, lesson);
        return new GrammarTutorContext(grammar, new GrammarTutorContext.QuestionContext(
                question.getQuestionCode(), question.getQuestionType().name(), question.getQuestionContent(),
                question.getOptions(), submitted.getAnswer(), question.getCorrectAnswer(),
                submitted.getIsCorrect(), question.getExplanation()));
    }
}
