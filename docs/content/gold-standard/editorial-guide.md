# English A1 Gold Standard Editorial Guide

## Purpose

This guide governs the Stage 8C.1 pack for A1-009, A1-012, A1-016, A1-019, and A1-020. It
uses the existing content source, validators, review states, and Micro Lesson flow. It does not
approve content, change runtime architecture, or authorize generation for any other GrammarPoint.

Specifications: [A1-009](A1-009.md), [A1-012](A1-012.md), [A1-016](A1-016.md),
[A1-019](A1-019.md), and [A1-020](A1-020.md).

## Authoring sequence

Every pack must be produced in this order:

```text
GrammarPoint specification
  -> Micro Lesson
  -> two Quick Checks
  -> capability-based blueprint
  -> traceable candidate generation without a disclosed keep quota
  -> independent AI editorial review
  -> reviewer-selected AI drafts
```

The generator does not know or optimize for a final retained count. The reviewer may reject any
number of candidates, including all of them, and never targets a predetermined warning mix.
Quantity is an audit observation, not a quality target. A candidate may be retained only when
its answer is unambiguous, its English is natural, its vocabulary and grammar are prerequisite-safe,
its distractors diagnose a plausible error, and its explanation states the rule and applies it to
the current sentence.

## Mandatory dependency and review rules

1. **Prerequisite-safe.** Every grammatical structure in prompts, options, examples, Micro Lessons,
   and explanations must be either the current teaching target or already learned through the
   prerequisite DAG and pedagogical learning path. A sentence being short does not make its grammar
   prerequisite-safe.
2. **One Primary Variable.** An item should introduce only one new primary grammar variable. Context
   may be familiar, but must not require simultaneous discovery of a modal, agreement rule, question
   system, or other later structure.
3. **Distractor-safe.** Wrong options must stay within the learner's current grammar inventory and
   represent a plausible error. Future grammar is not a convenient distractor pool.
4. **Independent Review.** The generator creates candidates without knowing a keep quota. The
   reviewer independently accepts or rejects according to evidence and may return an uneven result.
5. **Learning Path over Stable Code Order.** `A1-NNN` is a stable content identity, not an instruction
   to teach nodes numerically. Actual availability and sequencing come from an acyclic prerequisite
   DAG plus the approved pedagogical learning order.

Warnings are findings, never KPIs. Authors and generators must not deliberately create defective
items to produce duplicate, ambiguity, vocabulary, grammar, or explanation-warning counts.

## Scope control

- Teach one clear problem per GrammarPoint.
- Progress from understand and recognize to form, apply, diagnose, and transfer.
- Prefer family, school, home, food, animals, books, places, and daily objects.
- Prefer be, have, like, know, see, want, read, eat, drink, play, and live.
- Do not introduce exceptions merely to appear complete.
- Do not use commercial textbooks, paid banks, or protected exercise sites as source material.

The Grammar Cat voice is brief, calm, friendly, and useful. It may point out what to notice, but
must not be childish, flattering, emoji-heavy, or verbose.

## Candidate identity and metadata

Retained content lives only in `backend/src/main/resources/content/en/a1/curriculum.json`.
Specifications provide the editorial metadata that the frozen runtime schema does not persist:

- `grammarPointCode`;
- editorial `lessonCode` (`A1-NNN-L01` through `L03`, mapped to Lesson sort order);
- stable `questionCode`;
- `questionType`;
- primary `testedObjective`;
- `difficulty`;
- `targetCommonError`, when applicable;
- `sourceType = AI_DRAFT` (stored as JSON `provenance`);
- `reviewStatus = REVIEW_REQUIRED`.

Rejected candidates keep their reserved codes in the specification only. They are not imported,
and their codes must not be silently reused without a new review.

Two deliberate schema boundaries remain. Micro Lesson has no duplicate `title` field; Flutter uses
the owning GrammarPoint title as the lesson title. Likewise, `lessonCode`, `testedObjective`, and
`targetCommonError` stay in these version-controlled specifications because the Stage 8B runtime
model is frozen. Stable question codes join each retained row to its full prompt, answer, and
explanation in the authoritative curriculum JSON.

## Type and explanation rules

- `SINGLE_CHOICE` has exactly one defensible option id.
- `MULTIPLE_CHOICE` has at least two defensible correct ids; never use it for artificial balance.
- `FILL_BLANK` lists every accepted basic answer needed by the prompt.
- `SENTENCE_ORDER` uses exactly the same token multiset in options and answer.
- `TRUE_FALSE` tests one explicit claim and uses Boolean values.
- `CORRECTION` identifies a real error and supplies an accepted corrected sentence.

Every explanation names the relevant rule, applies it to the actual word or sentence, and briefly
addresses the likely error where useful. “The answer is B” is always rejected.

## Review checklist

For every candidate, the reviewer checks:

1. objective and blueprint fit;
2. prerequisite and Not Yet boundary;
3. one clear answer under the stated basic rule;
4. natural A1 English and controlled vocabulary;
5. evaluator-compatible answer shape;
6. useful distractors and explanation;
7. exact, normalized, and name-only duplication;
8. provenance and review status.

## Stage 8C.1 aggregate review

| Metric | Count |
| --- | ---: |
| Generated candidates | 100 |
| Rejected before source import | 20 |
| Retained in curriculum source | 80 |
| Near-duplicate warnings | 5 |
| Ambiguity warnings | 5 |
| Vocabulary warnings | 0 |
| Out-of-scope grammar warnings | 5 |
| Explanation warnings | 5 |
| Retained exact duplicates | 0 |
| Retained normalized duplicates | 0 |
| New `AI_DRAFT` | 80 |
| New `REVIEW_REQUIRED` | 80 |
| New `APPROVED` | 0 |

This is first-pass Stage 8C.1 experimental history, not a production template or target
distribution. Each point happened to generate 20 candidates, reject four, and retain 16; each also
happened to record one duplicate, ambiguity, grammar, and explanation warning. Future generators
must not reproduce this pattern deliberately. Warning counts describe actual first-pass findings,
and the five specifications retain the item-level record and blueprint coverage.

### Retained QuestionType distribution

| GrammarPoint | Single | Multiple | Fill | Order | True/False | Correction | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A1-009 | 4 | 2 | 3 | 2 | 2 | 3 | 16 |
| A1-012 | 3 | 3 | 3 | 2 | 2 | 3 | 16 |
| A1-016 | 4 | 2 | 3 | 3 | 2 | 2 | 16 |
| A1-019 | 4 | 2 | 3 | 2 | 2 | 3 | 16 |
| A1-020 | 4 | 2 | 3 | 3 | 2 | 2 | 16 |
| **New 8C.1** | **19** | **11** | **15** | **12** | **10** | **13** | **80** |
| **Whole source** | **27** | **19** | **23** | **20** | **18** | **21** | **128** |

Every point covers recognize, form, apply, diagnose, and transfer through its declared blueprint;
coverage is 16/16 retained objectives for each point and 80/80 for the pack.

## Runtime validation boundary

Static JSON parsing, identity checks, answer-shape checks, state counts, and deterministic duplicate
checks are part of this VM review. The new content remains `REQUIRES_MAC_VALIDATION` for the Java
validators, evaluator regression, Maven package, real database import/idempotency, Flutter tests,
and Android journey. No item may become `APPROVED` as a result of automated validation alone.

## Recorded UX / content-architecture debt

Many current prompts embed interaction instructions such as `Choose the...`, `Select all...`,
`Fill in the blank...`, `True or false...`, and `Put the words...`. These strings are UI interaction
labels as much as learning content. A future design may let Flutter localize a standard instruction
from `QuestionType`, leaving the stored prompt focused on the language task. This is recorded debt
only: Stage 8C.1 does not change Flutter, the question schema, or existing prompt behavior.
