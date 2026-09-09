# Stage 9A — Grammar Cat Tutor MVP

Code is implemented; runtime acceptance is **REQUIRES_MAC_VALIDATION**. This VM has no usable Java or Flutter command. No provider request with real credentials has been made. No Stage 9B or 8C.2 work is included.

## Ownership and baseline

Only the current agent wrote the shared workspace. Initial `pwd` was `C:\Mac\Home\Documents\grammar-agent`. Git initially rejected the shared filesystem ownership; commands were rerun with the command-local option `-c safe.directory='%(prefix)///psf/Home/Documents/grammar-agent'`. No persistent Git configuration changed.

Initial status was only ` M backend/mvnw`; initial diff stat was one file, zero added/deleted lines. This inherited wrapper change was not edited. Initial diff check passed with a CRLF advisory. No add, commit, push, reset, restore, clean, stash, switch, checkout, merge, rebase or origin change was performed.

## Changed file inventory

The 17 new AI implementation files are listed in the architecture tree below. Other new files are the five AI test files listed under Tests, this document, and:

```text
mobile/lib/features/tutor/data/tutor_repository.dart
mobile/lib/features/tutor/presentation/tutor_sheet.dart
mobile/test/tutor_test.dart
```

Existing files modified in this stage:

```text
.env.example
README.md
backend/pom.xml
backend/src/main/java/com/grammaragent/ai/package-info.java
backend/src/main/java/com/grammaragent/common/enums/ErrorCode.java
backend/src/main/java/com/grammaragent/question/repository/QuestionRepository.java
backend/src/main/java/com/grammaragent/question/repository/MyBatisQuestionRepository.java
backend/src/main/java/com/grammaragent/question/repository/UserAnswerRepository.java
backend/src/main/java/com/grammaragent/question/repository/MyBatisUserAnswerRepository.java
backend/src/main/resources/application.yml
backend/src/test/java/com/grammaragent/auth/security/SecurityConfigurationIntegrationTest.java
mobile/lib/core/network/api_client.dart
mobile/lib/features/course/presentation/course_screens.dart
mobile/lib/features/lesson/presentation/lesson_screens.dart
mobile/test/learning_entry_test.dart
```

The inherited `backend/mvnw` status remains outside this stage's edits. No curriculum, DAG, editorial document, migration or learning-state implementation file is modified.

## Backend architecture

```text
com/grammaragent/ai/
  agent/GrammarTutorAgent.java
  config/AiTutorConfig.java
  config/AiTutorProperties.java
  context/GrammarContextBuilder.java
  context/GrammarTutorContext.java
  context/GrammarScopePolicy.java
  controller/GrammarTutorController.java
  dto/GrammarTutorChatRequest.java
  dto/GrammarTutorChatResponse.java
  dto/TutorMessage.java
  dto/SuggestedQuestion.java
  llm/LLMProvider.java
  llm/LLMGateway.java
  llm/OpenAiCompatibleProvider.java
  llm/DisabledLLMProvider.java
  prompt/GrammarPromptManager.java
  service/GrammarTutorService.java
```

`LLMProvider.chat(ChatRequest)` accepts vendor-neutral role/content messages and returns explanation text. `GrammarTutorAgent` depends on the gateway, prompt manager and context builder. The implementation uses existing Spring `RestClient` with a dedicated JDK HTTP client; no AI framework or vendor SDK is added. A custom provider bean can replace the default bean. Future local routing/persistence/quota features are not implemented.

`DisabledLLMProvider` returns business code `50310`. Disabled, missing-key, incomplete and invalid configuration select it without failing AI bean creation. `GrammarTutorService` also rejects unavailable requests before database context reads. Existing database/JWT configuration is still required as before.

## Configuration

Set these **only in the backend process environment** (or a private ignored `.env` loaded into that environment):

```dotenv
AI_TUTOR_ENABLED=false
AI_BASE_URL=
AI_API_KEY=
AI_MODEL=
```

To enable, set the flag to `true`, fill the API root, model and private key, then restart the backend. `AI_BASE_URL` must be the API root that precedes `/chat/completions`, usually ending in `/v1`; do not include `/chat/completions` twice. There is no default vendor. `.env` is not automatically loaded by Spring: use the project's existing startup environment-loading procedure or IDE environment settings. Never place keys in Flutter, source files, command-line examples committed to Git, or logs.

Optional environment variables: `AI_TIMEOUT_SECONDS` defaults to 30 (1–60), `AI_TEMPERATURE` to 0.3 (0–2), `AI_MAX_TOKENS` to 600 (1–2000). Invalid bounds disable the provider. Connect timeout is capped at 10 seconds; response timeout uses the configured value. Redirects are disabled. Flutter uses a 90-second receive timeout for the tutor call only; other API requests retain their current timeouts. No automatic LLM retry or second suggestion-generation call is made.

## Authoritative context and safety

The audit found `GrammarCatalogService.getGrammarPoint` already composes `GrammarCatalogRepository` data with `CurriculumKnowledgeService`/`CurriculumContentLoader` Micro Lessons. This is reused. `QuestionRepository` and `UserAnswerRepository` gain only read methods; their existing write methods and learning callers are unchanged.

Grammar context includes ID/code/title/difficulty, description, grammar rule, examples, common errors, prerequisites, and a teaching-field allowlist from Micro Lesson: learning objective, introduction, core rule, structure/pattern, examples, common mistakes, memory tip, and optional scope fields. Quick Check keys are excluded.

Runtime Micro Lesson currently has no explicit In Scope/Not Yet fields. Maven packages the **existing unmodified** five `docs/content/gold-standard/A1-*.md` files as classpath resources. `GrammarScopePolicy` extracts section 3 only, never the later question audit. A missing or malformed Gold Standard boundary fails closed for that tutor request. Other points receive a conservative objective/core-rule boundary. Build from the full repository so these authoritative documents are available; an IDE should run Maven resource processing before launching. No copied curriculum or new course database is introduced.

For a question request, the backend:

1. Resolves the enabled Question by code and verifies the requested grammar point matches.
2. Reads the latest submitted `UserAnswer` for the authenticated user and exact question, ordered by `answeredAt DESC, id DESC`.
3. Verifies ownership, question identity and stored answer/result presence, then uses the existing enabled-lesson/context checks.
4. Builds context with question code/type/content/options, stored user answer, server canonical answer/explanation, and stored deterministic correctness.

Unsubmitted, unknown, mismatched and other-user questions are rejected before any LLM call with `40310`. The API does not take a client answer or an attempt ID; when a question has multiple submissions, the latest persisted one (including a review submission) is used. A fresh sheet is opened for each page/question; old page history is discarded on close. Without a submitted question, the model receives no formal question, answer key or canonical explanation.

`QuestionAnswerEvaluator` remains the only grader. No Tutor write dependency on Mastery, XP, Review, WrongQuestion, LessonAttempt or LessonProgress is added. Context reads use a read-only transaction, ending before the provider call. No schema/migration/conversation table changes.

## Prompt and history

`GrammarPromptManager` alone owns the system prompt. It sets Grammar Cat identity, user-language response, concise level-appropriate explanations, Learning Objective/Core Rules/In Scope/Not Yet, Prerequisite-safe and One Primary Variable constraints. It prohibits grading, changing canonical answers, disclosing internal prompts/keys/context dumps, or claiming learning-state updates.

The provider receives one system message and one JSON data message partitioned into `courseContext`, `untrustedHistory`, and `userQuestion`. History roles may only be user/assistant and remain untrusted data, including claimed assistant replies; they never become provider system messages or evidence of grading. JSON encoding prevents text from breaking the structural partition. These are basic prompt boundaries, not a guarantee against every model-level injection; the hard security boundaries are server authorization, withheld unsubmitted answer keys, and absence of state-write capabilities.

Maximum current message: 2000 characters. History: at most 8 messages, at most 2000 characters each, validated by backend DTO/service. Flutter stores only the latest 8 page-session messages and bounds history before sending. There is no persistence or long-term memory.

## API

Both endpoints use the existing JWT security policy and `ApiResponse` envelope.

`GET /api/v1/ai/tutor/status?scene=teaching|wrong|answered` returns `available` plus four deterministic `{text}` suggestions. Scene selects wording only; it supplies no question context or authorization and performs no LLM call. Availability means configured, not an active provider health probe.

`POST /api/v1/ai/tutor/chat`:

```json
{
  "grammarPointId": 16,
  "message": "为什么 apple 用 an？",
  "questionCode": "A1-016-Q001",
  "history": [{"role": "user", "content": "请简单解释一下"}]
}
```

`grammarPointId` is the server's numeric database ID, **not necessarily 16 for A1-016**; use the ID returned by the course API. Omit `questionCode` in Teaching mode. Omit history or send an empty list for a new page. Unknown fields, including `correctAnswer`, `userAnswer`, `canonicalExplanation`, `systemPrompt`, `apiKey`, `model` and `userId`, are rejected with 40000 even when global Jackson ignores unknown properties.

Successful envelope data:

```json
{
  "answer": "apple 以元音音素开头，所以这里用 an。",
  "suggestedQuestions": [
    {"text": "为什么我的答案错了？"},
    {"text": "为什么正确答案是这个？"},
    {"text": "能换一种方式解释吗？"},
    {"text": "再给我一个类似例子。"}
  ]
}
```

The returned question templates are selected from the actual persisted correctness. Correct-answer mode does not suggest “why was I wrong?”. Provider/model/internal context are not exposed in the response.

| Condition | Business code | HTTP |
| --- | --- | --- |
| Disabled/missing config/provider 401 or 403 | 50310 | 503 |
| Timeout/provider 408 or 504 | 50410 | 504 |
| Provider rate limit | 42910 | 429 |
| Provider 5xx, malformed/blank/oversized response or transport failure | 50210 | 502 |
| Question not submitted/accessible | 40310 | 403 |
| Invalid input/extra fields | 40000 | 400 |

Only safe static business messages reach Flutter. Provider exception causes/bodies are discarded. Logs record generated request ID, latency and success flag without request bodies, Authorization headers, keys or full prompts. Provider authentication failure is never returned as HTTP 401, avoiding accidental user logout/token refresh.

## Flutter MVP

`features/tutor/data/tutor_repository.dart` reuses `ApiClient` and its existing auth behavior. `features/tutor/presentation/tutor_sheet.dart` supplies a simple modal sheet with four backend suggestions, text input, Send, answers, loading/error states and Close. There is no new routing dependency, voice, streaming UI or learning-state mutation.

Entries are present on Grammar Point detail, Teaching Page 1 and Teaching Page 2. Formal Question feedback has a wrong-answer entry (“不明白为什么？问 Grammar Cat”) or a weaker correct-answer entry. No tutor question entry is shown before submission. If older question data has no question code, the feedback entry is omitted safely.

Opening the sheet fetches status. Disabled AI displays “Grammar Cat AI 暂未开启，你可以继续学习。” and disables sending. Status failure offers recheck. Provider failures preserve custom input for retry; send buttons are disabled in flight. Closing during a request is safe through mounted checks; completion is discarded after close. Closing does not cancel an already sent provider request.

## Tests and actual execution

New backend test files:

- `ai/GrammarTutorAgentTest`: fake provider, context-builder call, prompt partitions/scope, one completion, suggestions.
- `ai/GrammarContextBuilderTest`: no teaching keys, unsubmitted and cross-user denial, matching grammar point, canonical stored answer, correct/incorrect result, Gold Standard extraction, read-only/no-learning-write dependencies.
- `ai/GrammarTutorControllerTest`: extra-field rejection, validation/history limits, authenticated identity and public response.
- `ai/AiTutorConfigTest`: disabled/missing-key bean startup, health and deterministic evaluator remain usable, disabled service avoids agent, provider replacement.
- `ai/OpenAiCompatibleProviderTest`: mock HTTP compatible payload, 401/429/5xx, timeout, malformed/empty/oversized output and sanitized failures.

Existing security integration test adds both protected Tutor paths. Flutter adds `tutor_test.dart` covering wire payload, history/timeout bounds, disabled state, four suggestions, custom input/history, duplicate-send prevention, retry and dispose safety. `learning_entry_test.dart` adds both Teaching entries and formal correct/wrong feedback visibility/context.

Actual attempts in this VM:

- `backend: .\mvnw.cmd test` exited 1 before running tests: `JAVA_HOME environment variable is not defined correctly`.
- `mobile: flutter test` could not start: command not found.
- `java -version` and `flutter --version` could not start. No installation/environment change was attempted.
- `git diff --check` passed; Git emitted only LF/CRLF conversion advisories.

No newly added test is claimed to have passed. Existing `target` reports are prior artifacts and are not validation evidence for this change.

## Mac runtime acceptance — REQUIRES_MAC_VALIDATION

1. From `backend`, run `./mvnw test` and `./mvnw package`; verify packaged Gold Standard scope resources exist.
2. From `mobile`, run `dart format --output=none --set-exit-if-changed lib/features/tutor test/tutor_test.dart`, `flutter analyze`, and `flutter test`. Apply formatter output as needed and rerun checks on Mac.
3. Start existing PostgreSQL/Redis/backend with valid existing app settings and AI disabled. Verify Auth, Course, Question, Mastery and Review still work; Tutor status is unavailable and UI returns to learning normally.
4. Enable backend-only provider configuration, confirm Teaching suggestions/custom questions and multi-turn answers work on a device/emulator.
5. Submit a formal wrong answer, open Tutor and verify the explanation matches server answer/feedback. Repeat with a correct answer and verify the weaker entry.
6. Call Tutor with an unsubmitted question, a different user's submitted question, a mismatched point, and client `correctAnswer`; expect rejection without provider calls. Verify anonymous chat/status requests return 401.
7. Exercise provider timeout, bad credentials, rate limit, malformed response and network failure. Check safe UI messages and unaffected learning flow.
8. Compare learning-state/XP/review rows before and after Tutor-only calls: no changes. Verify no keys or complete prompts appear in logs or Flutter traffic.
9. Try scope and prompt-injection probes, including A1-016 spelling/sound exceptions and requests to disclose system prompts. Model behavior requires real-provider review; it is not proven by unit tests.

Recommended handoff: Agent A performs Mac Runtime Validation. Stage 9A is **CODE COMPLETE**, with runtime acceptance pending. Do not proceed to Stage 9B/8C.2, commit or push as part of this handoff.
