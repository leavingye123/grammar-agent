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
  -> 20-25 traceable candidates
  -> independent AI editorial review
  -> 12-16 retained AI drafts
```

Quantity is a ceiling and audit aid, not a quality target. A candidate may be retained only when
its answer is unambiguous, its English is natural, its vocabulary and grammar are prerequisite-safe,
its distractors diagnose a plausible error, and its explanation states the rule and applies it to
the current sentence.

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

Each point generated 20 candidates, rejected four independently identifiable weak candidates,
and retained 16. Warning counts describe rejected candidates and are intentionally not hidden.
The five specifications contain the item-level decisions and complete blueprint coverage.

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
