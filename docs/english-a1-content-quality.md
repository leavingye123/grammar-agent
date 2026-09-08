# English A1 Content Quality Foundation

## 1. Stage 8B adjusted scope

Stage 8B no longer targeted a bulk question count. The executable content source remains
`backend/src/main/resources/content/en/a1/`, and its 48-question baseline is retained as candidate
production content. Stage 8C.1 later added a bounded Gold Standard pack for exactly A1-009,
A1-012, A1-016, A1-019, and A1-020; it did not resume the abandoned A1-009 through A1-023 batch.

AI-created content is not production-approved by default. All 128 current questions are explicitly
classified as `AI_DRAFT` with `REVIEW_REQUIRED` status until an independent editorial review is completed.

## 2. Stage 8B baseline inventory

| Grammar Point | Topic | Questions | Type distribution |
| --- | --- | ---: | --- |
| A1-001 | Basic sentence structure | 6 | 1 of each supported type |
| A1-002 | Subject pronouns | 6 | 1 of each supported type |
| A1-003 | be affirmative | 6 | 1 of each supported type |
| A1-004 | be contractions | 6 | 1 of each supported type |
| A1-005 | be negative | 6 | 1 of each supported type |
| A1-006 | be yes/no questions | 6 | 1 of each supported type |
| A1-007 | Basic question words | 6 | 1 of each supported type |
| A1-008 | be wh-questions | 6 | 1 of each supported type |
| **Total** |  | **48** | **8 of each supported type** |

The six supported types are `SINGLE_CHOICE`, `MULTIPLE_CHOICE`, `FILL_BLANK`,
`SENTENCE_ORDER`, `TRUE_FALSE`, and `CORRECTION`.

## 3. Quality audit result

The audit checked answer structure and uniqueness, English naturalness, A1 vocabulary,
explanation usefulness, exact and normalized duplicates, name-only variants, ambiguous context,
meaningless distractors, and out-of-scope grammar.

Automated and manual review found five clear quality issues: the multiple-choice explanations in
`A1-003-Q006`, `A1-004-Q006`, `A1-005-Q006`, `A1-007-Q006`, and `A1-008-Q006` explained only
the incorrect option instead of explaining the full answer set. Those explanations were rewritten
without changing the prompt, answer, or learning objective.

After correction:

- validator errors: 0;
- missing explanations: 0;
- exact duplicates: 0;
- normalized duplicates: 0;
- mechanical name-only variants: 0;
- invalid or non-unique single answers: 0;
- detected out-of-scope vocabulary/grammar warnings: 0.

These checks establish a quality floor, not editorial approval. The 48 baseline questions and 80
Stage 8C.1 retained candidates remain `REVIEW_REQUIRED` because they have not passed human review.

The executable `QuestionContentValidator.QualityReport` currently reports:

| Metric | Count |
| --- | ---: |
| Questions | 128 |
| `AI_DRAFT` | 128 |
| `REVIEW_REQUIRED` | 128 |
| `APPROVED` | 0 |
| Exact duplicates | 0 |
| Normalized duplicates | 0 |
| Missing explanations | 0 |
| Validator errors | 0 |
| Validator warnings | 0 |
| Micro Lessons | 13 |
| Quick Checks | 26 |
| `READY` lessons | 39 |
| `COMING_SOON` lessons | 96 |

These values are assertions over the version-controlled source, not targets that content states
may be changed to satisfy. In particular, no draft is promoted merely to improve the report.

## 4. Stable question identity and versioning

Every question has a stable code in the form `A1-NNN-QNNN`. Database migration V3 stores it in
`questions.question_code`, makes it required, and enforces uniqueness. Content import uses this
code as question identity; removed source questions are disabled rather than deleted so historical
`user_answers`, wrong-question records, and analytics keep valid foreign keys.

Small non-semantic corrections, such as spelling or clearer explanation wording, may retain the
same code. If the tested rule, correct answer, or question meaning changes after release, create a
new question code and retire the old question instead of silently changing historical semantics.
The top-level content version and Git history record the source revision; a dedicated semantic
question version can be added when the editorial publishing workflow is introduced.

## 5. Provenance and review model

The content model supports these provenance values:

- `EDITORIAL`: edited or authored by the internal content team;
- `ORIGINAL`: independently authored original content;
- `AI_DRAFT`: AI-assisted draft that requires review;
- `OPEN_LICENSED`: legally reusable open content with source, licence, and attribution recorded;
- `LICENSED`: content used under an explicit commercial licence.

Review states are `DRAFT`, `REVIEW_REQUIRED`, and `APPROVED`. The intended publication path is:

```text
Draft/import -> structural validator -> duplicate/quality checks
             -> independent editorial review -> APPROVED -> learner-facing release
```

A future CMS may persist source URL, licence identifier, attribution, reviewer, review time, and
review notes. Until then, provenance and review status live in version-controlled content JSON.
Commercial textbooks, paid sites, and protected exercise platforms must not be copied. Research
imports may use only public-domain, suitably licensed Creative Commons, or formally licensed
sources, with traceable attribution.

## 6. Micro Lesson model

`micro-lessons.json` is a backend-owned content source. A Micro Lesson contains:

- `learningObjective`;
- `shortIntroduction`;
- `coreRule`;
- `structure`;
- worked `examples`;
- `commonMistakes` with correction and reason;
- optional `memoryTip`;
- one or two `quickCheck` items.

The first curated set covers A1-001 through A1-008 plus A1-009, A1-012, A1-016, A1-019, and
A1-020: 13 Micro Lessons and 26 Quick Checks. Quick Checks are embedded understanding checks,
not Question Bank records. They do not create `user_answers`, award XP, or affect Mastery.
The final editorial pass also made the A1-007 birthday example's intended date context explicit
and replaced one meaningless A1-016 distractor with a focused two-option `a`/`an` check.

The Flutter path is:

```text
Grammar Point -> 1-2 minute Micro Lesson -> Quick Check
              -> formal Lesson / Question -> Feedback -> Result
```

The existing green GrammarAgent design system is retained. Grammar Cat appears as a static
teaching companion; no LLM or agent behaviour is connected.

## 7. Content availability

The curriculum keeps all 45 Grammar Points and 135 meaningful Lesson shells. Only lessons with
at least one enabled formal question are marked `READY`; the rest are `COMING_SOON` and cannot
open an empty practice session. Current source content therefore has 39 ready lessons and 96
coming-soon lessons. A Grammar Point may still expose its Micro Lesson before its formal practice
content is ready.

## 8. Future Grammar Cat Tutor boundary

The backend knowledge service can supply a Grammar Point and its Micro Lesson without depending
on Flutter. A future Tutor Agent may compose that read-only knowledge with question explanation,
user mastery, and wrong-question context to implement Teach, Explain, and Review. The current
stage deliberately contains no LLM gateway, prompt execution, or agent workflow.
