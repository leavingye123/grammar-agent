# Stage 8B Acceptance Record

> This is the frozen Stage 8B baseline snapshot. The executable content source later advanced to
> the five-point Stage 8C.1 pack; see the [Gold Standard editorial guide](content/gold-standard/editorial-guide.md).

## Scope and handoff baseline

Stage 8B was resumed from the shared `grammar-agent` working tree rather than restarted. The
existing Stage 7B.1, 8A, and 8B changes were preserved; no branch, index state, SDK path, local
configuration, or content batch was replaced. At handoff the repository was on `main`, aligned
with `origin/main`, with 41 tracked files modified, 17 untracked files, and no staged changes.

The interrupted work was final regression and packaging. Stage 8B remains intentionally scoped
to the learning-content system and question-quality foundation. It does not generate the planned
A1-009 through A1-023 question batch and does not implement an AI tutor or Stage 8C features.

## Final content inventory

| Metric | Verified source value |
| --- | ---: |
| Chapters | 7 |
| Grammar Points | 45 |
| Lessons | 135 |
| Questions | 48 |
| `AI_DRAFT` questions | 48 |
| `REVIEW_REQUIRED` questions | 48 |
| `APPROVED` questions | 0 |
| Exact duplicates | 0 |
| Normalized duplicates | 0 |
| Missing explanations | 0 |
| Validator errors | 0 |
| Validator warnings | 0 |
| Micro Lessons | 13 |
| Quick Checks | 26 |
| `READY` lessons | 24 |
| `COMING_SOON` lessons | 111 |

The 48 questions cover A1-001 through A1-008, six per Grammar Point. Each supported QuestionType
appears eight times. The five reviewed multiple-choice explanation corrections remain present in
`A1-003-Q006`, `A1-004-Q006`, `A1-005-Q006`, `A1-007-Q006`, and `A1-008-Q006`; their prompts,
answers, types, and evaluation rules were not changed during this handoff.

## Quality and learning-flow acceptance

- `AI_DRAFT + APPROVED` is a validator error and is covered by a rejection test.
- Stable `questionCode` flows from JSON through import, migration, entity/repository, DTO, lesson
  question API, Review DTO, and Flutter parsing. Database ids remain internal relationship ids.
- Exact and normalized duplicate detection remains deterministic; no embedding or vector system
  was introduced.
- The executable quality report includes question/review/provenance, duplicate, explanation,
  validator, Micro Lesson, Quick Check, and lesson-availability counts.
- Micro Lessons contain learning objective, short introduction, core rule, structure, examples,
  common mistakes, optional memory tip, and Quick Checks. Coverage is A1-001 through A1-009 plus
  A1-012, A1-016, A1-019, and A1-020, excluding A1-010 and A1-011: 13 points in total.
- Structure-shaped text now requires only non-blank content; a regression test explicitly accepts
  the short valid structure `a book`. Core teaching prose retains its minimum-length check.
- Quick Checks are embedded read-only content evaluated in Flutter. They do not enter the
  `questions` table or call answer, WrongQuestion, Mastery, LessonAttempt, XP, or formal statistics
  services.
- The Flutter path remains Grammar Point -> Micro Lesson -> Quick Check -> formal Lesson/Practice
  -> Question -> Feedback -> Result.
- Lesson responses expose `questionCount` and `contentStatus`. Flutter disables entry to empty
  practice, and the backend rejects completion with `LESSON_HAS_NO_QUESTIONS` before reading an
  attempt or updating progress. A regression test covers that ordering.
- Import continues to upsert questions by stable code and disable removed content instead of
  deleting it. This preserves foreign keys from historical answers and review data.

## Provenance, licensing, and future tutor boundary

Question source supports editorial, original, AI-draft, open-licensed, and explicitly licensed
provenance, while review states remain `DRAFT`, `REVIEW_REQUIRED`, and `APPROVED`. AI drafts are
never implicitly approved. Commercial textbooks, paid question banks, and protected exercise
sites must not be copied; future research content must be original, public domain, commercially
compatible open-licensed, or explicitly licensed, with source/licence/attribution retained.

`CurriculumKnowledgeService` provides a read-only teaching-knowledge boundary suitable for a
future Grammar Cat Tutor context builder. No Qwen, OpenAI, LangChain, LangGraph, RAG, gateway, or
runtime agent integration is part of Stage 8B.

## Validation status

The current VM has neither `java` nor `flutter` on `PATH`, so the latest source cannot be executed
here without changing the shared development environment. Backend tests, Maven package, Flutter
analyze/tests, Debug APK build, Docker/PostgreSQL/Redis import, Android Emulator, adb, and the real
mobile E2E are therefore marked `REQUIRES_MAC_VALIDATION` for the final handoff.

Existing shared artifacts from the immediately preceding run show 68 Surefire tests with zero
failures/errors/skips and a generated Debug APK. These artifacts predate the two final Java
regression tests added during this handoff and are evidence of the prior run only, not a substitute
for rerunning the latest source. The previously recorded real-database acceptance remains: two
idempotent imports, 51 total questions, 48 enabled questions, 79 historical answers, 18 wrong
questions, and zero orphan foreign keys.

Stage 8B is ready to hand to the Mac environment for final runtime validation. Work must stop
after that validation and must not continue into Stage 8C as part of this acceptance pass.
