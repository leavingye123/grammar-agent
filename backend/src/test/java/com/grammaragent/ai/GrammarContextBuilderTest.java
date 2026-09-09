package com.grammaragent.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.grammaragent.ai.context.GrammarContextBuilder;
import com.grammaragent.ai.context.GrammarScopePolicy;
import com.grammaragent.common.enums.ErrorCode;
import com.grammaragent.common.exception.BusinessException;
import com.grammaragent.grammar.dto.GrammarPointDetailResponse;
import com.grammaragent.grammar.service.GrammarCatalogService;
import com.grammaragent.lesson.entity.Lesson;
import com.grammaragent.question.entity.Question;
import com.grammaragent.question.entity.UserAnswer;
import com.grammaragent.question.enums.QuestionType;
import com.grammaragent.question.repository.QuestionRepository;
import com.grammaragent.question.repository.UserAnswerRepository;
import com.grammaragent.question.service.QuestionContextService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.List;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class GrammarContextBuilderTest {
    final ObjectMapper mapper = new ObjectMapper();
    final GrammarCatalogService catalog = mock(GrammarCatalogService.class);
    final QuestionRepository questions = mock(QuestionRepository.class);
    final UserAnswerRepository answers = mock(UserAnswerRepository.class);
    final QuestionContextService questionContext = mock(QuestionContextService.class);
    final GrammarContextBuilder builder = new GrammarContextBuilder(catalog, questions, answers,
            questionContext, new GrammarScopePolicy(),
            mock(com.grammaragent.learning.repository.LessonAttemptRepository.class));
    Question question;

    @BeforeEach
    void setup() throws Exception {
        when(catalog.getGrammarPoint(16L)).thenReturn(new GrammarPointDetailResponse(
                16L, 1L, "A1-016", "a / an", "one thing", "first sound", null, null,
                mapper.readTree("""
                        {"learningObjective":"choose an article","coreRule":"first sound",
                         "structure":"a/an + noun","memoryTip":"listen","quickCheck":[{"correctOptionId":"SECRET"}]}
                        """), 1, 16, List.of()));
        question = new Question();
        question.setId(100L);
        question.setGrammarPointId(16L);
        question.setLessonId(20L);
        question.setQuestionCode("A1-016-Q001");
        question.setQuestionType(QuestionType.FILL_BLANK);
        question.setQuestionContent("This is ___ apple.");
        question.setCorrectAnswer(mapper.readTree("{\"answers\":[\"an\"]}"));
        question.setExplanation("apple starts with a vowel sound.");
        when(questions.findEnabledByCode(question.getQuestionCode())).thenReturn(Optional.of(question));
        when(answers.findLatestByUserAndQuestion(7L, 100L)).thenReturn(Optional.empty());
    }

    @Test
    void teachingNeverReadsQuestionsOrAnswerKeys() throws Exception {
        var context = builder.build(7L, 16L, null);
        assertNull(context.submittedQuestion());
        String json = mapper.writeValueAsString(context);
        assertFalse(json.contains("SECRET"));
        assertFalse(json.contains("quickCheck"));
        assertTrue(context.grammarPoint().scopeAndNotYet().contains("a university"));
        assertFalse(context.grammarPoint().scopeAndNotYet().contains("Q019"));
        verifyNoInteractions(questions, answers, questionContext);
    }

    @Test
    void unsubmittedQuestionCannotExposeCanonicalAnswer() {
        var exception = assertThrows(BusinessException.class,
                () -> builder.build(7L, 16L, "A1-016-Q001"));
        assertEquals(ErrorCode.AI_TUTOR_ANSWER_REQUIRED, exception.getErrorCode());
        verify(answers).findLatestByUserAndQuestion(7L, 100L);
        verifyNoMoreInteractions(answers);
        verifyNoInteractions(questionContext);
    }

    @Test
    void wrongAnswerUsesOwnedStoredSubmissionAndCanonicalQuestionOnly() throws Exception {
        UserAnswer submitted = submission(7L, false);
        when(answers.findLatestByUserAndQuestion(7L, 100L)).thenReturn(Optional.of(submitted));
        Lesson lesson = new Lesson();
        when(questionContext.requireEnabledLesson(20L)).thenReturn(lesson);
        var context = builder.build(7L, 16L, "A1-016-Q001");
        assertEquals("a", context.submittedQuestion().userAnswer().asText());
        assertEquals("an", context.submittedQuestion().correctAnswer().path("answers").get(0).asText());
        assertFalse(context.submittedQuestion().deterministicCorrect());
        assertEquals(question.getExplanation(), context.submittedQuestion().canonicalExplanation());
        verify(questionContext).validateQuestion(question, lesson);
        // Exhaustive repository interaction check guards against accidental inserts/state mutations.
        verify(answers).findLatestByUserAndQuestion(7L, 100L);
        verify(questions).findEnabledByCode("A1-016-Q001");
        verifyNoMoreInteractions(answers, questions);
        assertEquals("a", submitted.getAnswer().asText());
        assertFalse(submitted.getIsCorrect());
    }

    @Test
    void correctSubmissionKeepsDeterministicResult() throws Exception {
        when(answers.findLatestByUserAndQuestion(7L, 100L)).thenReturn(Optional.of(submission(7L, true)));
        assertTrue(builder.build(7L, 16L, "A1-016-Q001").submittedQuestion().deterministicCorrect());
    }

    @Test
    void rejectsOtherUsersAndMismatchedGrammarPoint() throws Exception {
        when(answers.findLatestByUserAndQuestion(7L, 100L)).thenReturn(Optional.of(submission(8L, false)));
        assertThrows(BusinessException.class, () -> builder.build(7L, 16L, "A1-016-Q001"));
        question.setGrammarPointId(17L);
        assertThrows(BusinessException.class, () -> builder.build(7L, 16L, "A1-016-Q001"));
        assertThrows(BusinessException.class, () -> builder.build(null, 16L, null));
    }

    @Test
    void allGoldScopesLoadWithoutQuestionAuditAndUnknownPointIsConservative() {
        var scope = new GrammarScopePolicy();
        for (String code : List.of("A1-009", "A1-012", "A1-016", "A1-019", "A1-020")) {
            String text = scope.forPoint(code);
            assertTrue(text.contains("Not Yet"));
            assertFalse(text.contains("Q001"));
            assertFalse(text.contains("## 4."));
        }
        assertTrue(scope.forPoint("A1-001").contains("Learning Objective"));
    }

    @Test
    void contextReadIsTransactionalReadOnlyAndHasNoLearningStateDependencies() throws Exception {
        var transaction = GrammarContextBuilder.class.getMethod("build", Long.class, Long.class, String.class)
                .getAnnotation(org.springframework.transaction.annotation.Transactional.class);
        assertTrue(transaction.readOnly());
        for (var field : GrammarContextBuilder.class.getDeclaredFields()) {
            String type = field.getType().getName();
            assertFalse(type.contains(".learning.") && !type.endsWith("LessonAttemptRepository"), type);
            assertFalse(type.contains(".review."), type);
            assertFalse(type.contains("WrongQuestion"), type);
            assertFalse(type.contains("QuestionAnswerEvaluator"), type);
        }
    }

    private UserAnswer submission(Long userId, boolean correct) throws Exception {
        var answer = new UserAnswer();
        answer.setUserId(userId);
        answer.setQuestionId(100L);
        answer.setAnswer(mapper.readTree(correct ? "\"an\"" : "\"a\""));
        answer.setIsCorrect(correct);
        return answer;
    }
}
