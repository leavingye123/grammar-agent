# English A1 Question Bank v1

## Current scope

Stage 8B established a 48-question baseline for A1-001 through A1-008 and intentionally stopped
before bulk generation. Stage 8C.1 then added a reviewed Gold Standard sample of 80 retained
candidates for A1-009, A1-012, A1-016, A1-019, and A1-020. The current source therefore contains
128 `AI_DRAFT + REVIEW_REQUIRED` questions and zero approved questions. Inventory, audit findings,
stable-code/version rules, provenance, and review workflow are recorded in
[English A1 Content Quality Foundation](english-a1-content-quality.md); the five-point authoring
process is recorded in the [Gold Standard editorial guide](content/gold-standard/editorial-guide.md).

## Question blueprint

New Grammar Point content must be planned against the learning objective before questions are
written. A blueprint may draw from these dimensions, without mechanically assigning equal counts:

- rule recognition;
- form and structure;
- short daily-life context application;
- error diagnosis and correction;
- a review variant that changes the reasoning context, not only a person's name;
- contrast only when two genuinely confusable forms belong inside the learner's prerequisites.

Question placement follows each Lesson objective. `MULTIPLE_CHOICE` is used only when two or more
answers are genuinely correct; a type is never added simply to balance a distribution.

## Type and answer rules

- `SINGLE_CHOICE`: one option id and exactly one defensible answer.
- `MULTIPLE_CHOICE`: at least two correct option ids, all present in the options.
- `FILL_BLANK`: an explicit non-empty accepted-answer list.
- `SENTENCE_ORDER`: answer tokens must be the same multiset as the supplied tokens.
- `TRUE_FALSE`: a Boolean answer.
- `CORRECTION`: an explicit non-empty list of accepted corrected sentences.

All six types are evaluated by the existing deterministic `QuestionAnswerEvaluator`. Flutter does
not determine correctness, and production questions are never generated at request time.

## Vocabulary control

Question authors should prefer short prerequisite-safe language from familiar A1 contexts:
family, school, home, food, hobbies, shops, parks, time, and simple travel or conversation. Common
verbs include be, have, like, go, play, read, eat, drink, watch, study, work, live, and want.
Vocabulary pools are difficulty controls, not templates for random name replacement.

## Explanation standard

An explanation should name the relevant rule, connect it to the actual subject/context or form,
and briefly address the likely mistake. It must not merely repeat an option letter. A1 explanations
stay short and concrete.

## Publication gate

```text
Authored or licensed draft
  -> answer/schema validator
  -> exact, normalized, and mechanical-variant detection
  -> language, level, ambiguity, distractor, and licence review
  -> APPROVED
  -> learner-facing release
```

The next question batch should begin only after a human reviewer signs off the current candidate
bank and a per-Grammar-Point blueprint. Quantity is not an acceptance target.
