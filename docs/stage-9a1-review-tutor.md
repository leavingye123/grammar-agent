# Stage 9A.1 — Grammar Cat Review Integration

Stage 9A.1 is CODE COMPLETE; runtime acceptance is REQUIRES_MAC_VALIDATION.

Wrong Questions and due Review keep their existing entry and submission flow. The current Review question displays Grammar Cat only after its submission has returned deterministic feedback. Advancing resets feedback, so the next unanswered question has no Tutor entry.

- Incorrect: an outlined “🐱 还是没弄懂？问 Grammar Cat” button opens the shared sheet.
- Correct: a secondary text “还有疑问？问 Grammar Cat” button opens the shared sheet; Continue/Complete remains the filled primary action.
- Existing `wrong` / `answered` scenes and four deterministic recommendations are reused, with no extra LLM call.
- Existing `POST /api/v1/ai/tutor/chat`, TutorRepository and GrammarTutorSheet are reused. The request sends only grammarPointId, questionCode, message and bounded history. Canonical answers/explanations remain server-owned.
- The existing Review list response now adds `grammarPointId` from Question. Flutter treats the field as optional for older server responses and omits the Tutor entry if the ID/code is absent. No answer key is added to the list response.
- Sheet history remains at most eight messages and is discarded on close. Disabled/unavailable AI stays within the sheet and does not block Continue/Complete.

No evaluator, Mastery/XP/Review decision logic, database schema, curriculum or DAG change. No new AI endpoint, provider configuration, persistence or Stage 9B work.

Files changed for this stage:

1. `backend/src/main/java/com/grammaragent/review/dto/ReviewQuestionResponse.java`
2. `backend/src/main/java/com/grammaragent/review/service/ReviewQueryService.java` (response projection only)
3. `backend/src/test/java/com/grammaragent/review/service/ReviewQueryServiceTest.java` (one ID assertion)
4. `mobile/lib/features/review/domain/review_models.dart`
5. `mobile/lib/features/review/domain/review_models.g.dart` (matching serialization update; generator unavailable in VM)
6. `mobile/lib/features/review/presentation/review_screens.dart`
7. `mobile/lib/features/tutor/presentation/tutor_sheet.dart`
8. `mobile/test/review_tutor_test.dart`
9. This document.

Three small widget scenarios cover wrong/correct feedback and disabled AI, entry absence before submission and on the next question, shared sheet opening, allowed actual request fields, and continuing Review after closing. The existing backend response test now checks grammarPointId alongside its no-answer-leak assertions.

Mac validation: compile backend and run ReviewQueryServiceTest; regenerate JSON serialization with the existing Flutter build_runner workflow; run Flutter analyze and `flutter test test/review_tutor_test.dart test/tutor_test.dart`; verify Wrong Questions → Review → submit → Tutor → follow-up → next/complete on a device, including AI disabled. Java/Flutter are unavailable in the current VM, so these checks are not claimed as passed. Existing Stage 9A edits remain in the shared working tree; no commit or push is performed.
