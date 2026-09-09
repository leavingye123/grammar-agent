# Stage 9A.2 — Grammar Cat Lesson Result Summary

Stage 9A.2 is CODE COMPLETE; execution and device acceptance are REQUIRES_MAC_VALIDATION.

## Product flow

Formal Lesson completion still calculates and persists the score, correct count, XP and progress through existing deterministic services. The completion response additionally returns its exact `lessonAttemptId`. Result displays a secondary Grammar Cat card below the primary continuation/return actions. It says either “想看看这次哪里需要注意吗？” or recognizes an all-correct result.

Entering Result makes no Tutor status or LLM request. Clicking “帮我总结这次练习” opens the existing GrammarTutorSheet, checks availability, loads server-selected result suggestions, then sends that explicit summary question once. Follow-up uses the same sheet, API and eight-message session limit. Failed summary calls preserve the question for manual retry. Closing clears the sheet session.

Disabled AI displays the existing unavailable message and sends no LLM request. Closing returns to unchanged Result actions. Older completion responses without an attempt ID omit the entry; the client never guesses the latest attempt or derives an ID from a score.

## API and authorization

The existing `POST /api/v1/ai/tutor/chat` accepts one of two exclusive contexts:

- Existing Teaching/Feedback: `grammarPointId`, optional `questionCode`.
- Result: `lessonAttemptId` only.

Both also accept `message` and bounded `history`. Example Result body:

```json
{"lessonAttemptId":99,"message":"帮我总结这次练习","history":[]}
```

No score, XP, Mastery, user ID, canonical answer or client error list is accepted. Unknown fields continue to be rejected. Combining an attempt ID with a grammar point/question is rejected.

The existing status endpoint supports `scene=result&lessonAttemptId=99`. If AI is configured, its recommendations are derived from the owned completed attempt with no LLM call. Disabled status returns unavailable and no recommendations without reading an attempt. It never returns an answer key or hidden result context.

`GrammarContextBuilder.buildResult` performs read-only checks:

1. Query `LessonAttemptRepository.findByUserAndId` with authenticated user ID and attempt ID; check both identifiers again on the returned record.
2. Require `status=COMPLETED`, non-null completion time, persisted score/XP/counts, and valid counts.
3. Reuse enabled Lesson/Question services and `findLatestByQuestionIdsInAttempt`. The existing latest-answer query now also maps `lesson_attempt_id` and JSON `answer`; its filter/order and all grading callers stay unchanged.
4. Require a complete, unique per-question set belonging to that exact user and attempt, with timestamps no later than completion. Check lesson/question relationships and count consistency. A subsequent Review or different Formal Attempt is never used.
5. Include only wrong-question details in model context. Missing/inconsistent data is rejected before any provider call with safe business code `40311`; unknown, other-user and unfinished attempts use the same error.

The MVP limits summaries to at most 50 questions in a single attempt and does not truncate hidden questions into a misleading summary. It requires the current enabled lesson question set to match the stored attempt count. Canonical question text/answers come from the current authoritative Question records; there is no new historical-content snapshot or database migration.

## Context, recommendations and prompt

Result context contains current GrammarPoint teaching/scope data; Lesson ID/title; exact Attempt ID/completion time; stored score, total/correct count and XP; wrong count; and each wrong question's code/type/content/options, stored submitted answer, canonical answer/explanation and persisted incorrect result. Wrong count is a deterministic count/integrity check, not LLM grading. Score and XP are never recalculated by Tutor.

Result with mistakes: “我这次主要错在哪里？”, “这个知识点怎么记？”, “能再解释一下我错的题吗？”, “接下来应该注意什么？”

All correct: “帮我总结这次用到的规则”, “这个知识点怎么记？”, “再给我一个简单例子”, “接下来应该注意什么？”

Both initial and reply recommendations use server correctness. GrammarPromptManager treats lessonResult as verified data, forbids recalculating/changing scores or inventing mistakes when all correct, and restricts explanations to this lesson and its Scope/Not Yet boundaries. It prohibits psychological/medical traits, global proficiency conclusions and broad learning plans. No second Agent, provider or chat UI exists.

## Files changed this stage

- Backend completion plumbing: `learning/dto/LessonCompletionResponse.java`, `learning/service/LessonCompletionService.java` (response ID only), `learning/repository/LessonAttemptRepository.java`, `learning/repository/MyBatisLessonAttemptRepository.java` (read query only).
- Existing answer projection: `question/mapper/UserAnswerMapper.java`.
- AI: `ai/dto/GrammarTutorChatRequest.java`, `ai/context/GrammarTutorContext.java`, `ai/context/GrammarContextBuilder.java`, `ai/agent/GrammarTutorAgent.java`, `ai/service/GrammarTutorService.java`, `ai/controller/GrammarTutorController.java`, `ai/prompt/GrammarPromptManager.java`; shared `common/enums/ErrorCode.java`.
- Flutter: `features/lesson/domain/lesson_models.dart`, `lesson_models.g.dart`, `features/lesson/presentation/lesson_screens.dart`, `features/tutor/data/tutor_repository.dart`, `features/tutor/presentation/tutor_sheet.dart` (all under `mobile/lib`).
- Backend tests: new `ai/LessonResultTutorTest.java`; updated `ai/GrammarContextBuilderTest.java`, `ai/GrammarTutorControllerTest.java`, `learning/service/LessonCompletionServiceTest.java`.
- Flutter tests: new `mobile/test/lesson_result_tutor_test.dart`; adjusted existing fake signatures in `mobile/test/tutor_test.dart`.
- This document.

No Mastery, XP calculation, Review decision/scheduler, WrongQuestion mutation, curriculum, DAG or schema changes. Prior Stage 9A/9A.1 work is preserved.

## Validation

Minimal new coverage: reject unfinished/cross-user attempts; isolate answers to the completed attempt; preserve stored score/XP; return only its actual wrong questions; reject client correctAnswer/score and mixed identifiers; verify all-correct/wrong recommendations; return completion attempt ID; defer AI until click; send only attempt/message/history; and keep return navigation usable with disabled AI.

Actual VM attempts:

- `backend: .\mvnw.cmd -Dtest=LessonResultTutorTest,GrammarTutorControllerTest,LessonCompletionServiceTest test` failed before test execution because JAVA_HOME is invalid.
- `mobile: flutter test test/lesson_result_tutor_test.dart test/tutor_test.dart test/review_tutor_test.dart` could not start because Flutter is unavailable.

REQUIRES_MAC_VALIDATION: Java compile/tests, Flutter analyze/tests and generated JSON verification, plus device testing of actual completion → summary → follow-up → next lesson. Verify isolation after later attempts/Review submissions, disabled-provider navigation, and unchanged persisted learning state after Tutor-only requests. No test is claimed to have passed here; no environment was installed or changed.

Stop at Stage 9A.2. No Stage 9B/8C.2, commit or push.
