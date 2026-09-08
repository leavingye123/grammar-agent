# English A1 Dependency Audit

## Executive Summary

This audit separates stable content codes from pedagogical learning order. It reviews all 45 A1
nodes against their topic, current prerequisite edges, declared objective/rule/examples, available
Micro Lessons and Questions, and downstream consumers. Only A1-001–009, A1-012, A1-016,
A1-019, and A1-020 currently have question content; conclusions for the remaining nodes are
forward-looking proposals based on their catalog definitions and example structures.

| Result | Count |
| --- | ---: |
| Total nodes | 45 |
| KEEP | 18 |
| ADD_PREREQUISITE | 15 |
| REMOVE_PREREQUISITE | 0 |
| REORDER_IN_LEARNING_PATH | 1 |
| SPLIT_SCOPE | 2 |
| REVIEW_REQUIRED | 9 |
| Current cycles | 0 |
| Potential cycle risks | 1 |
| BLOCKING nodes | 1 |

The current DAG is acyclic and every prerequisite reference exists. The only implemented edge in
this pass is `A1-016 -> A1-020`; it is local, required by the actual `a/an` structures in A1-020,
and remains acyclic. Every other recommendation below is **PROPOSED**, not a source change.

The principal dependency pattern is hidden grammar inside otherwise simple sentences: third-person
agreement in foundational tasks, future negation/question systems in quantifier work, articles in
noun/description work, and future structures used as distractors. A short sentence is not
automatically prerequisite-safe.

## Dependency Matrix

| Code | Topic | Current Prereq | Recommended Prereq | Verdict | Severity |
| --- | --- | --- | --- | --- | --- |
| A1-001 | Basic sentence skeleton | — | —; narrow content | SPLIT_SCOPE | HIGH |
| A1-002 | Subject pronouns | A1-001 | A1-001; revise content | REVIEW_REQUIRED | HIGH |
| A1-003 | be affirmative | A1-002 | A1-002; revise examples | REVIEW_REQUIRED | MEDIUM |
| A1-004 | be contractions | A1-003 | A1-003; revise distractor | REVIEW_REQUIRED | LOW |
| A1-005 | be negatives | A1-003 | A1-003; revise distractor | REVIEW_REQUIRED | MEDIUM |
| A1-006 | be yes/no questions | A1-003 | A1-003; revise distractor | REVIEW_REQUIRED | MEDIUM |
| A1-007 | Basic question words | A1-001 | A1-001, A1-006 | ADD_PREREQUISITE | HIGH |
| A1-008 | be wh-questions | A1-006, A1-007 | A1-006, A1-007; revise contexts | REVIEW_REQUIRED | MEDIUM |
| A1-009 | Object pronouns | A1-002 | A1-002 | KEEP | LOW |
| A1-010 | Possessive determiners | A1-002 | A1-002, A1-003 | ADD_PREREQUISITE | MEDIUM |
| A1-011 | Possessive pronouns | A1-010 | A1-010 | KEEP | LOW |
| A1-012 | Regular plurals | A1-001 | A1-001 | KEEP | LOW |
| A1-013 | Irregular plurals | A1-012 | A1-012 | KEEP | LOW |
| A1-014 | Noun possessives | A1-012 | A1-012; review sentence frames | REVIEW_REQUIRED | MEDIUM |
| A1-015 | this/that/these/those | A1-012 | A1-003, A1-012 | ADD_PREREQUISITE | MEDIUM |
| A1-016 | a/an | A1-012 | A1-003, A1-012 | ADD_PREREQUISITE | MEDIUM |
| A1-017 | the | A1-016 | A1-003, A1-016 | ADD_PREREQUISITE | MEDIUM |
| A1-018 | Countable/uncountable | A1-012 | A1-012, A1-016 | ADD_PREREQUISITE | HIGH |
| A1-019 | some/any | A1-018 | Decision pending; Option A: A1-018, A1-021, A1-027 | REORDER_IN_LEARNING_PATH | BLOCKING |
| A1-020 | There is/are affirmative | A1-003, A1-012, A1-016 | A1-003, A1-012, A1-016 | ADD_PREREQUISITE | HIGH |
| A1-021 | There is/are negative/questions | A1-020 | A1-020; remove assumed any | REVIEW_REQUIRED | HIGH |
| A1-022 | have/has got affirmative | A1-002 | A1-002; use full forms first | REVIEW_REQUIRED | MEDIUM |
| A1-023 | have/has got negative/questions | A1-022 | A1-022 | KEEP | LOW |
| A1-024 | Present simple affirmative | A1-001, A1-002 | A1-001, A1-002 | KEEP | LOW |
| A1-025 | Present simple third person | A1-024 | A1-024 | KEEP | LOW |
| A1-026 | Present simple negatives | A1-024, A1-025 | A1-024, A1-025 | KEEP | LOW |
| A1-027 | Present simple yes/no questions | A1-026 | A1-026 | KEEP | LOW |
| A1-028 | Present simple wh-questions | A1-007, A1-027 | A1-007, A1-027 | KEEP | LOW |
| A1-029 | Frequency adverbs | A1-024 | A1-003, A1-024 | ADD_PREREQUISITE | MEDIUM |
| A1-030 | Basic adverb position | A1-003, A1-024, A1-029 | A1-003, A1-024, A1-029 | KEEP | LOW |
| A1-031 | Present continuous affirmative | A1-003 | A1-003 | KEEP | LOW |
| A1-032 | Present continuous negative/questions | A1-031 | A1-005, A1-006, A1-031 | ADD_PREREQUISITE | HIGH |
| A1-033 | Present simple vs continuous | A1-024, A1-031 | A1-024, A1-031 | KEEP | LOW |
| A1-034 | can/can't ability | A1-001 | A1-001, A1-002 | ADD_PREREQUISITE | MEDIUM |
| A1-035 | can permission/requests | A1-034 | A1-009, A1-034 | ADD_PREREQUISITE | MEDIUM |
| A1-036 | Imperatives | A1-001 | A1-001 | KEEP | LOW |
| A1-037 | Let's suggestions | A1-036 | A1-036 | KEEP | LOW |
| A1-038 | Adjective position | A1-003, A1-012 | A1-003, A1-012, A1-016 | ADD_PREREQUISITE | HIGH |
| A1-039 | Manner adverbs | A1-038 | A1-024, A1-038 | ADD_PREREQUISITE | HIGH |
| A1-040 | Place prepositions | A1-012 | A1-003, A1-012, A1-017 | ADD_PREREQUISITE | HIGH |
| A1-041 | Time prepositions | A1-024 | A1-024 | KEEP | LOW |
| A1-042 | and/but/or/because | A1-001 | split; coordinators after A1-024, because after A1-003/A1-024 | SPLIT_SCOPE | HIGH |
| A1-043 | Comparatives | A1-038 | A1-038 | KEEP | LOW |
| A1-044 | Superlatives | A1-043 | A1-017, A1-043 | ADD_PREREQUISITE | HIGH |
| A1-045 | Integrated word order | A1-024, A1-030, A1-040, A1-041 | unchanged | KEEP | LOW |

## Node-by-node findings

## A1-001

- Topic: basic `Subject + Verb (+ Object/Complement)` skeleton.
- Current prerequisites: none. True prior knowledge: none; this must remain an entry node.
- Hidden/future knowledge: current questions use third-person `reads/likes/drinks` from A1-025 and
  `are` from A1-003. These introduce agreement/copular variables before they are taught.
- Verdict: **SPLIT_SCOPE / HIGH**. Recommended prerequisites remain none; narrow examples to plural
  or `I/you/we/they + base verb`, and postpone be-complement analysis.
- Order/cycle/risk: code position is suitable and no cycle is possible. Risk is foundational
  assessment measuring later agreement instead of sentence completeness.

## A1-002

- Topic: subject pronouns. Current prerequisite: A1-001; required knowledge is the subject slot.
- Hidden/future knowledge: current content relies on `am/is/are` from A1-003 and uses `him/us` from
  A1-009 as distractors.
- Verdict: **REVIEW_REQUIRED / HIGH**. Keep A1-001; rewrite examples around safe base-verb frames
  and use already introduced subject forms as distractors.
- Order/cycle/risk: it must remain before A1-003, so adding A1-003 would create a conceptual loop.

## A1-003

- Topic: affirmative `am/is/are`. Current prerequisite: A1-002; this is structurally sufficient.
- Hidden/future knowledge: `books/cats` examples assume plural morphology from A1-012.
- Verdict: **REVIEW_REQUIRED / MEDIUM**. Keep A1-002 and prefer pronouns or transparent supplied
  nouns until plural formation is taught.
- Order/cycle/risk: no order conflict or cycle; risk is a secondary plural decision in be items.

## A1-004

- Topic: affirmative be contractions. Current prerequisite: A1-003; sufficient.
- Hidden/future knowledge: a Quick Check contrasts `we're` with past `were`, which is outside the
  declared A1 inventory rather than a taught common error.
- Verdict: **REVIEW_REQUIRED / LOW**. Keep A1-003 and replace the future-tense distractor.
- Order/cycle/risk: no cycle or code-order conflict; low risk is distractor contamination.

## A1-005

- Topic: be negatives. Current prerequisite: A1-003; sufficient for `be + not`.
- Hidden/future knowledge: `He don't at home` imports do-negation from A1-026 as a distractor.
- Verdict: **REVIEW_REQUIRED / MEDIUM**. Keep A1-003 and use be-order/agreement errors only.
- Order/cycle/risk: no cycle; unsafe distractors may teach an unexplained future form.

## A1-006

- Topic: be yes/no questions and short answers. Current prerequisite: A1-003; sufficient.
- Hidden/future knowledge: `Do you are tired?` imports do-questions from A1-027.
- Verdict: **REVIEW_REQUIRED / MEDIUM**. Keep A1-003; distractors should rearrange known be forms.
- Order/cycle/risk: no cycle; current item adds an avoidable second question system.

## A1-007

- Topic: what/who/where/when/how. Current prerequisite: A1-001.
- Hidden/future knowledge: actual examples and questions use `Where is`, `How are`, and complete be
  questions, so A1-006 is already required in practice.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed prerequisites: A1-001 and A1-006.
- Order/cycle/risk: learning order should place this after be questions despite its stable code;
  no cycle results because A1-006 does not depend on A1-007.

## A1-008

- Topic: be special questions. Current prerequisites: A1-006 and A1-007; core needs are covered.
- Hidden/future knowledge: repeated `your` contexts assume A1-010, but possession is not necessary
  to test word order.
- Verdict: **REVIEW_REQUIRED / MEDIUM**. Keep edges and replace avoidable possessive contexts rather
  than making ownership grammar mandatory.
- Order/cycle/risk: correct DAG placement; content leakage, not node ordering, is the risk.

## A1-009

- Topic: object pronouns. Current prerequisite: A1-002; A1-001 is available transitively.
- Hidden/future knowledge: previous `can` and third-person-singular frames were removed in this pass.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-002; use only subject/object contrast
  and `I/we/they + base verb + object pronoun`.
- Order/cycle/risk: no cycle or code-order conflict after revision; Mac validation remains pending.

## A1-010

- Topic: possessive determiners. Current prerequisite: A1-002.
- Hidden/future knowledge: declared examples use affirmative be (`This is my bag`, `Their house is
  small`), so current sentence-level application assumes A1-003.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed: A1-002 and A1-003; avoid requiring A1-015 or
  adjective grammar as separate decisions.
- Order/cycle/risk: no cycle; pedagogical placement after be affirmative may differ from code order.

## A1-011

- Topic: standalone possessive pronouns. Current prerequisite: A1-010.
- Hidden/future knowledge: `the seats` in an expected example invokes A1-017 unnecessarily; `It is
  mine` can demonstrate the target once the proposed A1-003 support reaches this node via A1-010.
- Verdict: **KEEP / LOW**, conditional on safe examples and the upstream A1-010 proposal.
- Order/cycle/risk: no cycle; do not turn the definite article into a hidden mastery condition.

## A1-012

- Topic: regular plurals `-s/-es`. Current prerequisite: A1-001; required number cues and sentence
  skeleton are sufficient for the controlled scope.
- Hidden/future knowledge: prior `There are` content from A1-020 was removed in this pass.
- Verdict: **KEEP / LOW**. Retain A1-001 and `I/We + base verb + number + plural` frames.
- Order/cycle/risk: no cycle; irregular, y/f/o rules remain outside scope.

## A1-013

- Topic: common irregular plurals. Current prerequisite: A1-012; sufficient.
- Hidden/future knowledge: none inherent when practiced as noun phrases with explicit numbers.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-012.
- Order/cycle/risk: no cycle or order conflict; sentence contexts must stay prerequisite-safe.

## A1-014

- Topic: noun possessives including singular `'s` and regular plural apostrophe.
- Current prerequisite: A1-012; it is necessary for the `parents'` branch.
- Hidden/future knowledge: examples use be, articles, and adjective predicates that are not needed
  to assess the apostrophe rule.
- Verdict: **REVIEW_REQUIRED / MEDIUM**. Keep A1-012; use phrase-level or already-learned frames.
- Order/cycle/risk: no cycle; do not remove A1-012 unless plural possessive scope is split off.

## A1-015

- Topic: this/that/these/those. Current prerequisite: A1-012.
- Hidden/future knowledge: sentence patterns `This is.../Those are...` require A1-003; possessive
  examples may also leak A1-010 without being essential.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed: A1-003 and A1-012; keep possessives optional.
- Order/cycle/risk: no cycle; learning order should follow be affirmative and number distinction.

## A1-016

- Topic: `a/an`. Current prerequisite: A1-012.
- Hidden/future knowledge: basic sentence application uses familiar be frames; adjective phrases
  are extended transfer, not basic mastery. The future `some` distractor and unnecessary `has`
  frames were removed.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed prerequisites: A1-003 and A1-012.
- Order/cycle/risk: no cycle; this proposed edge is not implemented in this pass.

## A1-017

- Topic: definite `the`. Current prerequisite: A1-016.
- Hidden/future knowledge: repeated-mention examples use affirmative be in the second sentence.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed: A1-003 and A1-016; keep description vocabulary
  from becoming an adjective lesson.
- Order/cycle/risk: no cycle; pedagogical order remains after indefinite articles.

## A1-018

- Topic: countable versus uncountable nouns. Current prerequisite: A1-012.
- Hidden/future knowledge: the example `some water` leaks A1-019; the contrast with forbidden
  `a/an + uncountable` genuinely benefits from A1-016.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed: A1-012 and A1-016; replace `some water` with bare
  `water` or another scope-safe contrast.
- Order/cycle/risk: no cycle. Keeping `some` here would make A1-018 and A1-019 semantically circular.

## A1-019

- Topic: affirmative `some`, negative/question `any`. Current prerequisite: A1-018.
- Hidden/future knowledge: current content requires `don't` (A1-026), `Do...?` (A1-027), and
  `Are there...?` (A1-021).
- Verdict: **REORDER_IN_LEARNING_PATH / BLOCKING**. No source edge is changed. Option A proposes
  A1-018, A1-021, A1-027; Options B/C split or defer scope in the A1-019 specification.
- Order/cycle/risk: stable code cannot dictate placement. Adding A1-019 to A1-021 while also making
  A1-019 depend on A1-021 would cycle; A1-021 must first stop assuming `any`.

## A1-020

- Topic: affirmative `There is/There are` by number.
- Current prerequisites: A1-003, A1-012, and newly added A1-016.
- Hidden/future knowledge: `a/an` was a real missing dependency; negative/question forms remain out.
- Verdict: **ADD_PREREQUISITE / HIGH**, implemented only for A1-016 in this pass.
- Order/cycle/risk: `A1-016 -> A1-020` is acyclic. Wording now asks whether the following thing is
  one or more than one rather than claiming a noun immediately follows is/are.

## A1-021

- Topic: There is/are negatives and questions. Current prerequisite: A1-020; structurally sufficient.
- Hidden/future knowledge: declared `Are there any cafés?` assumes A1-019, but A1-019 itself may
  need A1-021. This is the identified cycle risk.
- Verdict: **REVIEW_REQUIRED / HIGH**. Keep A1-020 and use explicit numbers/bare plurals until the
  A1-019 learning-order decision is approved.
- Order/cycle/risk: do not add A1-019 now; revise example content to keep the DAG acyclic.

## A1-022

- Topic: `have/has got` affirmative. Current prerequisite: A1-002.
- Hidden/future knowledge: `I've got` assumes contraction handling beyond the core full forms;
  third-person `has got` is taught here and need not depend on A1-025.
- Verdict: **REVIEW_REQUIRED / MEDIUM**. Keep A1-002; present full forms before contractions.
- Order/cycle/risk: no cycle; do not conflate `has got` with present-simple `-s` mastery.

## A1-023

- Topic: `have/has got` negatives and questions. Current prerequisite: A1-022; sufficient.
- Hidden/future knowledge: none inherent because `haven't/hasn't` and inversion are current targets.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-022.
- Order/cycle/risk: no cycle or stable-code conflict.

## A1-024

- Topic: present-simple affirmative with base verbs. Current prerequisites: A1-001 and A1-002.
- Hidden/future knowledge: none inherent when limited to I/you/we/they as declared.
- Verdict: **KEEP / LOW**. Recommended prerequisites unchanged.
- Order/cycle/risk: no cycle; it is the appropriate supplier for many later verb-based contexts.

## A1-025

- Topic: present-simple third-person `-s/-es`. Current prerequisite: A1-024; sufficient.
- Hidden/future knowledge: none inherent; noun-plural `-s` must be contrasted but not retested.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-024.
- Order/cycle/risk: no cycle; later content must not pull this rule into earlier items implicitly.

## A1-026

- Topic: present-simple `don't/doesn't`. Current prerequisites: A1-024 and A1-025; sufficient.
- Hidden/future knowledge: none inherent because auxiliary choice and base-verb reset are targets.
- Verdict: **KEEP / LOW**. Recommended prerequisites unchanged.
- Order/cycle/risk: no cycle; supplies the negative branch required by full-scope A1-019.

## A1-027

- Topic: present-simple Do/Does questions. Current prerequisite: A1-026; upstream 024/025 are
  transitively available.
- Hidden/future knowledge: none inherent.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-026.
- Order/cycle/risk: no cycle; supplies the ordinary-question branch required by full A1-019.

## A1-028

- Topic: present-simple wh-questions. Current prerequisites: A1-007 and A1-027; sufficient.
- Hidden/future knowledge: none inherent when familiar verbs and question words are used.
- Verdict: **KEEP / LOW**. Recommended prerequisites unchanged.
- Order/cycle/risk: no cycle; code order and pedagogical dependencies agree.

## A1-029

- Topic: frequency-adverb position with lexical verbs and be.
- Current prerequisite: A1-024. Hidden knowledge: the explicit be-position branch needs A1-003.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed: A1-003 and A1-024.
- Order/cycle/risk: no cycle; avoid adjectives such as `kind` becoming a second unlearned target.

## A1-030

- Topic: basic adverb placement. Current prerequisites: A1-003, A1-024, A1-029.
- Hidden/future knowledge: generic sentence-final place/time does not require teaching all A1-040/041
  prepositions when examples use safe words such as `here` and `every day`.
- Verdict: **KEEP / LOW**. Recommended prerequisites unchanged.
- Order/cycle/risk: no cycle; detailed prepositional selection remains in later nodes.

## A1-031

- Topic: present-continuous affirmative `be + V-ing`. Current prerequisite: A1-003.
- Hidden/future knowledge: ing formation is part of this point; present-simple knowledge is not
  required until the contrast node.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-003.
- Order/cycle/risk: no cycle; keep time contrast out until A1-033.

## A1-032

- Topic: present-continuous negatives and questions. Current prerequisite: A1-031.
- Hidden/future knowledge: transformations reuse be-negative and be-question operations from
  A1-005 and A1-006, but those edges are absent.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed: A1-005, A1-006, and A1-031.
- Order/cycle/risk: no cycle; explicit edges prevent reteaching two earlier operations as new ones.

## A1-033

- Topic: present simple versus present continuous. Current prerequisites: A1-024 and A1-031.
- Hidden/future knowledge: none inherent; the two contrasted forms are both supplied.
- Verdict: **KEEP / LOW**. Recommended prerequisites unchanged.
- Order/cycle/risk: no cycle; use transparent time cues without requiring A1-041.

## A1-034

- Topic: `can/can't` for ability. Current prerequisite: A1-001.
- Hidden/future knowledge: examples require choosing subject pronouns; A1-002 is not explicit.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed: A1-001 and A1-002.
- Order/cycle/risk: no cycle; can itself owns invariant modal + base-verb structure.

## A1-035

- Topic: `can` for permission and requests. Current prerequisite: A1-034.
- Hidden/future knowledge: `Can you help me?` requires an object pronoun from A1-009.
- Verdict: **ADD_PREREQUISITE / MEDIUM**. Proposed: A1-009 and A1-034, unless all request examples
  are rewritten without object pronouns.
- Order/cycle/risk: no cycle; stable code order already places both suppliers earlier.

## A1-036

- Topic: positive and negative imperatives. Current prerequisite: A1-001.
- Hidden/future knowledge: imperative `Don't` is a construction taught inside this point and need
  not depend on declarative do-negation.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-001.
- Order/cycle/risk: no cycle; keep the distinction from A1-026 explicit in explanations.

## A1-037

- Topic: `Let's + base verb` suggestions. Current prerequisite: A1-036; sufficient.
- Hidden/future knowledge: none inherent; `Let's not` can be taught as this point's negative form.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-036.
- Order/cycle/risk: no cycle or learning-order conflict.

## A1-038

- Topic: adjective after be versus before a noun. Current prerequisites: A1-003 and A1-012.
- Hidden/future knowledge: singular attributive phrases such as `a quiet room` require A1-016.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed: A1-003, A1-012, and A1-016; avoid requiring
  definite `the` unless A1-017 is also intentionally selected.
- Order/cycle/risk: no cycle; attribute/predicate position remains the only new variable.

## A1-039

- Topic: manner adverbs. Current prerequisite: A1-038.
- Hidden/future knowledge: applying adverbs to actions needs familiar present-simple verb frames;
  current examples use an imperative and third-person agreement.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed: A1-024 and A1-038; use `We/They + base verb`
  before challenge contexts.
- Order/cycle/risk: no cycle; prevents verb agreement from becoming a second variable.

## A1-040

- Topic: place prepositions. Current prerequisite: A1-012.
- Hidden/future knowledge: complete location sentences require be (A1-003) and determiner/article
  phrases; current examples use `the` from A1-017.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed: A1-003, A1-012, and A1-017.
- Order/cycle/risk: no cycle; learning order moves this after article foundations despite stable ID.

## A1-041

- Topic: time prepositions `at/on/in`. Current prerequisite: A1-024.
- Hidden/future knowledge: none inherent when phrases attach to familiar present-simple sentences.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-024.
- Order/cycle/risk: no cycle; calendar vocabulary must remain A1-level.

## A1-042

- Topic: `and/but/or/because`. Current prerequisite: A1-001.
- Hidden/future knowledge: joining clauses requires stable finite clauses; the source example uses
  past `stayed/was`, which is outside this A1 map. `because` is also cognitively heavier than the
  three coordinators.
- Verdict: **SPLIT_SCOPE / HIGH**. Proposed: teach and/but/or after A1-024; teach because after
  A1-003 and A1-024, with present-tense examples only.
- Order/cycle/risk: no graph cycle, but the combined scope violates One Primary Variable.

## A1-043

- Topic: adjective comparatives. Current prerequisite: A1-038; be and adjective position arrive
  transitively under the proposed upstream graph.
- Hidden/future knowledge: none inherent if transparent adjectives are chosen.
- Verdict: **KEEP / LOW**. Recommended prerequisite remains A1-038.
- Order/cycle/risk: no cycle; irregular comparison and difficult `more` vocabulary need scope control.

## A1-044

- Topic: adjective superlatives. Current prerequisite: A1-043.
- Hidden/future knowledge: the form normally requires definite `the`, taught in A1-017.
- Verdict: **ADD_PREREQUISITE / HIGH**. Proposed: A1-017 and A1-043.
- Order/cycle/risk: no cycle; code order is compatible once the article edge is explicit.

## A1-045

- Topic: integrated Subject + Verb + Object + Place + Time order.
- Current prerequisites: A1-024, A1-030, A1-040, A1-041; these cover the required branches.
- Hidden/future knowledge: none inherent if objects and noun phrases use previously learned forms.
- Verdict: **KEEP / LOW**. Recommended prerequisites unchanged.
- Order/cycle/risk: no cycle; this should be scheduled only after all four branches, regardless of
  code adjacency or chapter display order.

## Potential cycle analysis

The current graph has no cycle. Adding the accepted `A1-016 -> A1-020` edge also remains acyclic.
The single identified **potential** cycle is semantic and must not be implemented:

```text
A1-019 some/any -> A1-021 required for Are there...?
A1-021 current example -> A1-019 required for any
```

Resolution must make one direction authoritative. Option A removes assumed `any` from A1-021 and
then places A1-019 after A1-021. Option B splits A1-019. No edge involving A1-019 is changed now.

## Proposed edge set for product review

Except for the already implemented A1-020 edge, the following are proposals only:

- A1-006 -> A1-007
- A1-003 -> A1-010, A1-015, A1-016, A1-017, A1-029, A1-040
- A1-016 -> A1-018, A1-038, and **implemented** A1-020
- A1-005 + A1-006 -> A1-032
- A1-002 -> A1-034
- A1-009 -> A1-035
- A1-024 -> A1-039
- A1-017 -> A1-040, A1-044
- A1-019 redesign: decision pending; do not add edges yet

## Validation boundary

Static checks cover JSON parsing, code/reference uniqueness, current and proposed cycle analysis,
question count/state preservation, duplicate detection, and Markdown/source consistency. Java
validators, database import/idempotency, Flutter tests, and the Android journey remain Mac work.
