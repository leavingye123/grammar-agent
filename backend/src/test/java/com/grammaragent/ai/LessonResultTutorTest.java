package com.grammaragent.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.ai.agent.GrammarTutorAgent;
import com.grammaragent.ai.context.GrammarContextBuilder;
import com.grammaragent.ai.context.GrammarScopePolicy;
import com.grammaragent.ai.dto.GrammarTutorChatRequest;
import com.grammaragent.ai.llm.LLMGateway;
import com.grammaragent.ai.prompt.GrammarPromptManager;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.grammar.dto.GrammarPointDetailResponse;
import com.grammaragent.grammar.service.GrammarCatalogService;
import com.grammaragent.learning.entity.LessonAttempt;
import com.grammaragent.learning.enums.LessonAttemptStatus;
import com.grammaragent.learning.repository.LessonAttemptRepository;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.service.QuestionContextService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class LessonResultTutorTest {
    final ObjectMapper mapper = new ObjectMapper().findAndRegisterModules();
    final LessonAttemptRepository attempts = mock(LessonAttemptRepository.class);
    final GrammarCatalogService grammar = mock(GrammarCatalogService.class);
    final QuestionRepository questions = mock(QuestionRepository.class);
    final UserAnswerRepository answers = mock(UserAnswerRepository.class);
    final QuestionContextService questionContext = mock(QuestionContextService.class);
    final GrammarContextBuilder builder = new GrammarContextBuilder(grammar, questions, answers, questionContext,
            new GrammarScopePolicy(), attempts);
    final LessonAttempt attempt = new LessonAttempt();
    List<UserAnswer> submissions;

    @BeforeEach void setup() throws Exception {
        attempt.setId(99L);
        attempt.setUserId(7L);
        attempt.setLessonId(20L);
        attempt.setStatus(LessonAttemptStatus.COMPLETED);
        attempt.setCompletedAt(OffsetDateTime.parse("2026-09-08T01:00:00Z"));
        attempt.setTotalCount(2);
        attempt.setCorrectCount(1);
        attempt.setScore(73); // Persisted value must be read verbatim, never recomputed by Tutor.
        attempt.setXpEarned(4);
        when(attempts.findByUserAndId(7L, 99L)).thenReturn(Optional.of(attempt));
        var lesson = new Lesson();
        lesson.setId(20L);
        lesson.setGrammarPointId(16L);
        lesson.setTitle("a / an practice");
        when(questionContext.requireEnabledLesson(20L)).thenReturn(lesson);
        when(grammar.getGrammarPoint(16L)).thenReturn(new GrammarPointDetailResponse(
                16L, 1L, "A1-016", "a / an", "one thing", "choose by sound",
                null, null, null, 1, 16, List.of()));
        when(questions.findEnabledByLessonId(20L)).thenReturn(List.of(question(101L), question(102L)));
        submissions = List.of(answer(101L, false), answer(102L, true));
        when(answers.findLatestByQuestionIdsInAttempt(7L, List.of(101L, 102L), 99L)).thenReturn(submissions);
    }

    @Test void unfinishedOrOtherUserAttemptIsRejectedBeforeAnswersAreRead() {
        attempt.setStatus(LessonAttemptStatus.IN_PROGRESS);
        assertEquals(ErrorCode.AI_TUTOR_COMPLETED_ATTEMPT_REQUIRED,
                assertThrows(BusinessException.class, () -> builder.buildResult(7L, 99L)).getErrorCode());
        attempt.setStatus(LessonAttemptStatus.COMPLETED);
        attempt.setUserId(8L);
        assertThrows(BusinessException.class, () -> builder.buildResult(7L, 99L));
        assertThrows(BusinessException.class, () -> builder.buildResult(8L, 99L));
        verifyNoInteractions(answers, questions, grammar);
    }

    @Test void completedAttemptReadsStoredScoreAndOnlyItsWrongQuestionsWithoutWrites() {
        var result = builder.buildResult(7L, 99L).lessonResult();
        assertEquals(73, result.score());
        assertEquals(4, result.xpEarned());
        assertEquals(1, result.wrongCount());
        assertEquals(99L, result.lessonAttemptId());
        assertEquals(1, result.wrongQuestions().size());
        var wrong = result.wrongQuestions().getFirst();
        assertEquals("A1-016-Q101", wrong.questionCode());
        assertEquals("a", wrong.userAnswer().asText());
        assertEquals("an", wrong.correctAnswer().path("answers").get(0).asText());
        assertEquals("Use an before the vowel sound.", wrong.canonicalExplanation());
        verify(attempts).findByUserAndId(7L, 99L);
        verify(answers).findLatestByQuestionIdsInAttempt(7L, List.of(101L, 102L), 99L);
        verifyNoMoreInteractions(attempts, answers);
    }

    @Test void answerFromDifferentAttemptOrIncompleteRowsFailClosed() {
        submissions.getFirst().setLessonAttemptId(100L);
        assertThrows(BusinessException.class, () -> builder.buildResult(7L, 99L));
        submissions.getFirst().setLessonAttemptId(99L);
        when(answers.findLatestByQuestionIdsInAttempt(7L, List.of(101L, 102L), 99L)).thenReturn(List.of());
        assertThrows(BusinessException.class, () -> builder.buildResult(7L, 99L));
    }

    @Test void resultSuggestionsUseServerCorrectnessAndChatUsesExistingAgent() {
        var calls = new java.util.concurrent.atomic.AtomicInteger();
        var agent = new GrammarTutorAgent(builder, new GrammarPromptManager(mapper), new LLMGateway(request -> {
            calls.incrementAndGet();
            assertTrue(request.messages().get(1).content().contains("lessonResult"));
            return "本次练习总结";
        }));
        assertEquals("我这次主要错在哪里？", agent.resultSuggestions(7L, 99L).getFirst().text());
        assertEquals(0, calls.get());
        attempt.setCorrectCount(2);
        attempt.setScore(100);
        submissions.getFirst().setIsCorrect(true);
        var response = agent.chat(7L, new GrammarTutorChatRequest(null, "帮我总结这次练习", null, List.of(), 99L));
        assertEquals(1, calls.get());
        assertEquals(4, response.suggestedQuestions().size());
        assertTrue(response.suggestedQuestions().stream().noneMatch(q -> q.text().contains("错")));
    }

    private Question question(Long id) throws Exception {
        var question = new Question();
        question.setId(id);
        question.setLessonId(20L);
        question.setGrammarPointId(16L);
        question.setQuestionCode("A1-016-Q" + id);
        question.setQuestionType(QuestionType.FILL_BLANK);
        question.setQuestionContent("This is ___ apple.");
        question.setCorrectAnswer(mapper.readTree("{\"answers\":[\"an\"]}"));
        question.setExplanation("Use an before the vowel sound.");
        return question;
    }

    private UserAnswer answer(Long questionId, boolean correct) throws Exception {
        var answer = new UserAnswer();
        answer.setUserId(7L);
        answer.setQuestionId(questionId);
        answer.setLessonAttemptId(99L);
        answer.setAnsweredAt(attempt.getCompletedAt().minusMinutes(1));
        answer.setAnswer(mapper.readTree(correct ? "\"an\"" : "\"a\""));
        answer.setIsCorrect(correct);
        return answer;
    }
}
