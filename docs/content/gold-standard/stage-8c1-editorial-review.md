# Stage 8C.1 Editorial Review Pack

> 本文件是 2026-09-08 Revision Pass 后的只读审核快照，不是第二套内容源。Specification/Editorial Metadata 来自对应 `A1-NNN.md`，Micro Lesson/Quick Check 来自 `micro-lessons.json`，最终保留题来自 `curriculum.json`。如需修改内容，应修改权威源后重新整理；本文件中的所有候选仍为 `AI_DRAFT + REVIEW_REQUIRED`。

## Source of Truth

- [Editorial Guide](editorial-guide.md)
- [A1 Dependency Audit](../a1-dependency-audit.md)
- [Curriculum and retained questions](../../../backend/src/main/resources/content/en/a1/curriculum.json)
- [Micro Lessons and Quick Checks](../../../backend/src/main/resources/content/en/a1/micro-lessons.json)
- [A1-009 Specification](A1-009.md)
- [A1-012 Specification](A1-012.md)
- [A1-016 Specification](A1-016.md)
- [A1-019 Specification](A1-019.md)
- [A1-020 Specification](A1-020.md)

## Review status guardrail

- 本包不新增 Question 或 GrammarPoint。
- 本包不修改任何题目的 `provenance` 或 `reviewStatus`。
- A1-019 为 `BLOCKED — REQUIRES CURRICULUM REDESIGN`。
- 本包中的题目不是 `APPROVED`；它们等待产品经理/课程总编辑逐题验收。

---

# A1-009 Editorial Review

- Specification source：[A1-009.md](A1-009.md)
- Question source：[`curriculum.json`](../../../backend/src/main/resources/content/en/a1/curriculum.json)
- Micro Lesson source：[`micro-lessons.json`](../../../backend/src/main/resources/content/en/a1/micro-lessons.json)

## A. GrammarPoint Specification（现有原文）

# A1-009 Gold Standard Specification — Object Pronouns

## 1. Basic info

- Code / level / domain: `A1-009` / A1 / 代词与所属
- Prerequisite: `A1-002` subject pronouns
- Editorial lessons: `A1-009-L01` action objects, `L02` subject/object contrast, `L03` daily transfer

## 2. Learning objective and prior knowledge

After learning, the learner can identify and use `me`, `you`, `him`, `her`, `it`, `us`, and
`them` after a basic verb. The learner may rely only on subject pronouns, simple SVO order, and
base-form uses of the verbs like, know, see, call, and help with `I`, `we`, or `they`.

## 3. Core rules, scope, and Not Yet

- The action doer uses a subject form: `I/he/she/we/they`.
- The person or thing receiving the action uses `me/him/her/us/them`.
- `you` and `it` keep the same written form as subject and object pronouns.
- In scope: recognition, subject/object contrast, verb + object pronoun, simple statements.
- Not Yet: complex preposition patterns, relative/reflexive pronouns, and double-object structures.

Pattern: `Subject + Verb + object pronoun`.

## 4. Examples, common errors, and contrast

Examples: `I like him.`; `We know her.`; `We see them.`; `They help us.`; `I call you.`

Common errors:

- `I like she.` -> `I like her.`: the receiver of like needs an object form.
- `We know he.` -> `We know him.`: the receiver of know needs an object form.
- `Them like cats.` -> `They like cats.`: the action doer needs a subject form.

Contrast: ask “Who does the action?” for the subject form and “Who receives it?” for the object
form. Do not teach pronoun case as abstract terminology beyond this practical distinction.

## 5. Micro Lesson, memory tip, and Quick Checks

The 60–90 second Micro Lesson uses the four examples and first two errors above. Grammar Cat tip:
“这个地方很容易把 me 和 I 混在一起。先找动作，再看谁接到这个动作。”

Memory tip: “动作前的主角用主格，动作后的对象用宾格。”

1. `I call Anna. I call ___.` (`she` / `her` / `we`) -> `her`.
2. Choose the correct sentence: `They help us.` / `They help we.` / `Them help us.`
   -> `They help us.`.

## 6. Question blueprint

| Capability | Count | Retained codes |
| --- | ---: | --- |
| Recognition | 3 | Q001, Q003, Q012 |
| Subject/object contrast | 4 | Q004, Q007, Q011, Q015 |
| Fill blank | 3 | Q002, Q008, Q013 |
| Sentence application | 3 | Q005, Q010, Q014 |
| Correction | 3 | Q006, Q009, Q016 |
| **Total** | **16** | all three lessons |

## 7. Retained candidate metadata

All rows use `sourceType=AI_DRAFT` and `reviewStatus=REVIEW_REQUIRED`.

| Code | Lesson | Type | Tested objective | Diff. | Target common error |
| --- | --- | --- | --- | ---: | --- |
| Q001 | L01 | SINGLE_CHOICE | replace Ben with him after call | 1 | `call he` |
| Q002 | L01 | FILL_BLANK | replace Ben with him | 1 | `know he` |
| Q003 | L01 | TRUE_FALSE | recognize them as receiver | 1 | object role confusion |
| Q004 | L01 | SINGLE_CHOICE | select her after like | 1 | `like she` |
| Q005 | L01 | MULTIPLE_CHOICE | recognize two valid objects | 2 | `help we` |
| Q006 | L01 | CORRECTION | repair `like she` | 1 | `I like she` |
| Q007 | L02 | SINGLE_CHOICE | retain We as subject | 1 | `Us like` |
| Q008 | L02 | FILL_BLANK | use him after call | 1 | `call he` |
| Q009 | L02 | CORRECTION | repair `know he` | 1 | `We know he` |
| Q010 | L02 | SENTENCE_ORDER | form I call you | 1 | missing/misplaced object |
| Q011 | L02 | TRUE_FALSE | reject Them as subject | 2 | `Them like` |
| Q012 | L03 | SINGLE_CHOICE | replace two named people with them | 1 | `see they` |
| Q013 | L03 | FILL_BLANK | replace Anna and me with us | 2 | object-group confusion |
| Q014 | L03 | SENTENCE_ORDER | form We know him | 1 | subject/object reversal |
| Q015 | L03 | MULTIPLE_CHOICE | apply both pronoun roles | 2 | `Them know` |
| Q016 | L03 | CORRECTION | repair `help we` | 2 | `help we` |

Full prompts, answers, and explanations are authoritative in `curriculum.json`; codes above expand
to `A1-009-QNNN`.

## 8. Rejected candidates and quality review

All rejected rows are difficulty 1, `AI_DRAFT`, and `REVIEW_REQUIRED`; codes expand to
`A1-009-QNNN` and will not be imported.

| Code | Lesson/type | Tested objective | Candidate and answer | Proposed explanation | Warning / target error |
| --- | --- | --- | --- | --- | --- |
| Q017 | L01 / SINGLE_CHOICE | select him after call | `I call Tom. I call ___`; answer `him` | call needs object him | Near duplicate of retained Q001 |
| Q018 | L01 / FILL_BLANK | choose an object form | `They like ___.`; no single answer | none is defensible | Ambiguous: no antecedent identifies the object |
| Q019 | L03 / SINGLE_CHOICE | select reflexive object | sentence requiring `herself`; answer `herself` | subject and object are the same person | Grammar warning: reflexives are Not Yet |
| Q020 | L02 / SINGLE_CHOICE | contrast he/him | valid base-form contrast item; answer `B` | `B is correct.` | Explanation warning: no rule; targets `know he` |

Generated 20; rejected 4; kept 16. Duplicate 1, ambiguity 1, vocabulary 0, grammar 1,
explanation 1. All five blueprint capabilities are covered with no retained warning.

## 9. Mastery evidence

Evidence of transfer is consistent selection of subject versus object form with new people and
plural groups, correct production after a familiar base-form verb, and diagnosis of `like she`,
`know he`, and `help we` without relying on a memorized name sentence. Modal verbs and
third-person-singular verb formation are explicitly excluded from this mastery decision.

## B. 完整 Micro Lesson 与 Quick Check（权威源快照）

- Learning Objective：在基础句中识别并在动词后正确使用宾格人称代词。
- 自然引入：一个人执行动作时用主格；当动作落到这个人身上时，通常改用宾格。
- 核心规则：I、he、she、we、they 作主语；动作后的对象用 me、him、her、us、them。you 和 it 的形式不变。
- Pattern：`Subject + Verb + object pronoun`
- Examples：
  - `I like him.` — him 是 like 的对象。
  - `We know her.` — her 是 know 的对象。
  - `We see them.` — them 代替两个或更多的人或事物。
  - `They help us.` — us 表示动作帮助到“我们”。
  - `I call you.` — you 作宾语时形式不变。
- Common Errors：
  - `I like she.` → `I like her.` — like 后的对象要用宾格 her。
  - `We know he.` → `We know him.` — know 后的对象要用宾格 him。
- Memory Tip / Grammar Cat Tip：动作前的主角用主格，动作后的对象用宾格。
- Quick Checks：
  - **A1-009-MQ01**：I call Anna. I call ___.
    - `A`：`she`
    - `B`：`her`
    - `C`：`we`
    - correctAnswer：`B`
    - explanation：call 后需要宾格 her。
  - **A1-009-MQ02**：请选择宾格代词使用正确的句子。
    - `A`：`They help us.`
    - `B`：`They help we.`
    - `C`：`Them help us.`
    - correctAnswer：`A`
    - explanation：They 是动作执行者，us 是 help 后的动作对象。

## C. 最终保留 Candidate Questions（16 道）

### A1-009-Q001

- lessonCode：`A1-009-L01`
- questionType：`SINGLE_CHOICE`
- prompt：I call Ben. I call ___.
- options：
  - `A`：`he`
  - `B`：`him`
  - `C`：`they`
- correctAnswer：`{"optionId":"B"}`
- explanation：第二个 call 后需要动作对象；Ben 用宾格 him 指代。
- testedObjective：replace Ben with him after call
- difficulty：`1`
- targetCommonError：`call he`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q002

- lessonCode：`A1-009-L01`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: We know Ben. We know ___.
- options：—
- correctAnswer：`{"answers":["him"]}`
- explanation：Ben 是男生，在 know 后作宾语，所以用 him。
- testedObjective：replace Ben with him
- difficulty：`1`
- targetCommonError：`know he`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q003

- lessonCode：`A1-009-L01`
- questionType：`TRUE_FALSE`
- prompt：True or false: In “We see them”, “them” is who or what we see.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：them 是 see 的对象，因此这里使用宾格是正确的。
- testedObjective：recognize them as receiver
- difficulty：`1`
- targetCommonError：object role confusion
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q004

- lessonCode：`A1-009-L01`
- questionType：`SINGLE_CHOICE`
- prompt：I like Anna. I like ___.
- options：
  - `A`：`she`
  - `B`：`her`
  - `C`：`we`
- correctAnswer：`{"optionId":"B"}`
- explanation：Anna 在第二句是 like 的对象，所以用宾格 her。
- testedObjective：select her after like
- difficulty：`1`
- targetCommonError：`like she`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q005

- lessonCode：`A1-009-L01`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all sentences with a correct object pronoun.
- options：
  - `A`：`We know her.`
  - `B`：`I see them.`
  - `C`：`They help we.`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：A 的 her 和 B 的 them 都在动词后作宾语；C 应使用 us。
- testedObjective：recognize two valid objects
- difficulty：`2`
- targetCommonError：`help we`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q006

- lessonCode：`A1-009-L01`
- questionType：`CORRECTION`
- prompt：Correct the pronoun: I like she.
- options：—
- correctAnswer：`{"acceptedAnswers":["I like her."]}`
- explanation：she 是主格；like 后的动作对象要使用宾格 her。
- testedObjective：repair `like she`
- difficulty：`1`
- targetCommonError：`I like she`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q007

- lessonCode：`A1-009-L02`
- questionType：`SINGLE_CHOICE`
- prompt：Choose the subject pronoun: ___ like music.
- options：
  - `A`：`We`
  - `B`：`Us`
  - `C`：`Them`
- correctAnswer：`{"optionId":"A"}`
- explanation：空格是动作 like 的执行者，要用主格 We。
- testedObjective：retain We as subject
- difficulty：`1`
- targetCommonError：`Us like`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q008

- lessonCode：`A1-009-L02`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: We call Tom. We call ___.
- options：—
- correctAnswer：`{"answers":["him"]}`
- explanation：Tom 在 call 后是动作对象，所以用宾格 him。
- testedObjective：use him after call
- difficulty：`1`
- targetCommonError：`call he`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q009

- lessonCode：`A1-009-L02`
- questionType：`CORRECTION`
- prompt：Correct the pronoun: I know he.
- options：—
- correctAnswer：`{"acceptedAnswers":["I know him."]}`
- explanation：he 是主格；know 后的对象要改用宾格 him。
- testedObjective：repair `know he`
- difficulty：`1`
- targetCommonError：`We know he`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q010

- lessonCode：`A1-009-L02`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `you`
  - `I`
  - `call`
  - `.`
- correctAnswer：`{"tokens":["I","call","you","."]}`
- explanation：I 是主语，call 是动词；you 作宾语时形式保持不变。
- testedObjective：form I call you
- difficulty：`1`
- targetCommonError：missing/misplaced object
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q011

- lessonCode：`A1-009-L02`
- questionType：`TRUE_FALSE`
- prompt：True or false: “Them like cats” uses the correct subject pronoun.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":false}`
- explanation：句首是动作执行者，要用主格 They，不能用宾格 Them。
- testedObjective：reject Them as subject
- difficulty：`2`
- targetCommonError：`Them like`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q012

- lessonCode：`A1-009-L03`
- questionType：`SINGLE_CHOICE`
- prompt：I see Ben and Anna. I see ___.
- options：
  - `A`：`they`
  - `B`：`them`
  - `C`：`we`
- correctAnswer：`{"optionId":"B"}`
- explanation：Ben and Anna 表示两个人，在 see 后作宾语，所以用 them。
- testedObjective：replace two named people with them
- difficulty：`1`
- targetCommonError：`see they`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q013

- lessonCode：`A1-009-L03`
- questionType：`FILL_BLANK`
- prompt：They see Anna and me. They see ___.
- options：—
- correctAnswer：`{"answers":["us"]}`
- explanation：Anna and me 在这里表示被看见的“我们”，可用宾格 us 指代。
- testedObjective：replace Anna and me with us
- difficulty：`2`
- targetCommonError：object-group confusion
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q014

- lessonCode：`A1-009-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `him`
  - `know`
  - `We`
  - `.`
- correctAnswer：`{"tokens":["We","know","him","."]}`
- explanation：We 是主语，know 是基础动词，宾格 him 放在动词后。
- testedObjective：form We know him
- difficulty：`1`
- targetCommonError：subject/object reversal
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q015

- lessonCode：`A1-009-L03`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all sentences with the correct pronoun form.
- options：
  - `A`：`They see us.`
  - `B`：`We like it.`
  - `C`：`Them know Anna.`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：A 的 us 和 B 的 it 都作宾语；C 的动作执行者应使用主格 They。
- testedObjective：apply both pronoun roles
- difficulty：`2`
- targetCommonError：`Them know`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-009-Q016

- lessonCode：`A1-009-L03`
- questionType：`CORRECTION`
- prompt：Correct the pronoun: They help we.
- options：—
- correctAnswer：`{"acceptedAnswers":["They help us."]}`
- explanation：we 是主格；help 后的动作对象要使用宾格 us。
- testedObjective：repair `help we`
- difficulty：`2`
- targetCommonError：`help we`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

---

# A1-012 Editorial Review

- Specification source：[A1-012.md](A1-012.md)
- Question source：[`curriculum.json`](../../../backend/src/main/resources/content/en/a1/curriculum.json)
- Micro Lesson source：[`micro-lessons.json`](../../../backend/src/main/resources/content/en/a1/micro-lessons.json)

## A. GrammarPoint Specification（现有原文）

# A1-012 Gold Standard Specification — Regular Plurals -s / -es

## 1. Basic info

- Code / level / domain: `A1-012` / A1 / 名词与限定词
- Prerequisite: `A1-001` basic sentence structure
- Editorial lessons: `A1-012-L01` plural -s, `L02` common -es endings, `L03` quantity transfer

## 2. Learning objective and prior knowledge

After learning, the learner can form and use regular plurals for common nouns by adding `-s`, or
`-es` after the basic endings s, x, ch, and sh. The learner may rely on simple sentence order,
numbers, and familiar daily nouns.

## 3. Core rules, scope, and Not Yet

- Use a plural noun after two or more.
- Most common nouns add `-s`: `book -> books`, `cat -> cats`.
- Common nouns ending in s, x, ch, or sh add `-es`: `bus -> buses`, `box -> boxes`.
- In scope: recognize singular/plural, form basic -s/-es, use after a number, correct missing/wrong endings.
- Not Yet: the complete spelling system, nouns ending in y/f/o, and irregular plurals reserved for A1-013.

Pattern: `one + singular noun`; `two/more + plural noun`; `noun + s/es`.

## 4. Examples, common errors, and contrast

Examples: `one book / two books`; `one cat / three cats`; `one box / two boxes`;
`one bus / four buses`; `one dish / two dishes`; `one watch / two watches`.

Common errors:

- `two cat` -> `two cats`: a count above one needs a plural noun.
- `two boxs` -> `two boxes`: x takes `-es` in this basic pattern.
- `two watchs` -> `two watches`: ch takes `-es`.

Contrast: `-s` is the default; use the taught ending check only for s/x/ch/sh. Do not infer that
all English plurals follow these two rules.

## 5. Micro Lesson, memory tip, and Quick Checks

The 60–90 second Micro Lesson contrasts `books/cats` with `boxes/buses` and diagnoses the first
two errors. Grammar Cat tip: “先看数量，再看词尾。两个以上，名词要变成复数。”

All sentence examples use prerequisite-safe `I/We + base verb` frames. `There is/There are`
belongs to A1-020 and is not used as an assumed sentence frame here.

Memory tip: “多数加 -s；s、x、ch、sh 结尾先想到 -es。”

1. `three ___` (`cat` / `cats` / `cates`) -> `cats`.
2. Plural of `box` (`boxs` / `boxes` / `box`) -> `boxes`.

## 6. Question blueprint

| Capability | Count | Retained codes |
| --- | ---: | --- |
| Singular/plural recognition | 3 | Q001, Q003, Q012 |
| -s formation | 3 | Q002, Q005, Q006 |
| -es formation | 4 | Q007, Q008, Q009, Q011 |
| Fill in context | 1 | Q013 |
| Correction | 1 | Q015 |
| Context application | 4 | Q004, Q010, Q014, Q016 |
| **Total** | **16** | all three lessons |

## 7. Retained candidate metadata

All rows use `sourceType=AI_DRAFT` and `reviewStatus=REVIEW_REQUIRED`; codes expand to
`A1-012-QNNN`.

| Code | Lesson | Type | Tested objective | Diff. | Target common error |
| --- | --- | --- | --- | ---: | --- |
| Q001 | L01 | SINGLE_CHOICE | form cats | 1 | `cates` |
| Q002 | L01 | FILL_BLANK | form books after two | 1 | singular after two |
| Q003 | L01 | TRUE_FALSE | recognize two dogs | 1 | missing -s |
| Q004 | L01 | MULTIPLE_CHOICE | compare -s with x ending | 1 | `boxs` |
| Q005 | L01 | CORRECTION | repair three cat | 1 | missing -s |
| Q006 | L01 | SENTENCE_ORDER | use two books in a sentence | 1 | singular after two |
| Q007 | L02 | SINGLE_CHOICE | form boxes | 1 | `boxs` |
| Q008 | L02 | FILL_BLANK | form buses | 1 | `buss` / `bus` |
| Q009 | L02 | TRUE_FALSE | recognize dishes | 1 | `dishs` |
| Q010 | L02 | MULTIPLE_CHOICE | select valid -es forms | 2 | `watchs` |
| Q011 | L02 | CORRECTION | repair two boxs | 1 | `boxs` |
| Q012 | L03 | SINGLE_CHOICE | choose books after three | 1 | `bookes` |
| Q013 | L03 | FILL_BLANK | use buses after four | 2 | singular after four |
| Q014 | L03 | SENTENCE_ORDER | form We see three buses | 2 | wrong plural placement |
| Q015 | L03 | CORRECTION | repair two watchs | 2 | `watchs` |
| Q016 | L03 | MULTIPLE_CHOICE | transfer -s/-es by quantity | 2 | `three dish` |

## 8. Rejected candidates and quality review

All rejected rows are difficulty 1, `AI_DRAFT`, and `REVIEW_REQUIRED`; codes expand to
`A1-012-QNNN` and will not be imported.

| Code | Lesson/type | Tested objective | Candidate and answer | Proposed explanation | Warning / target error |
| --- | --- | --- | --- | --- | --- |
| Q017 | L01 / SINGLE_CHOICE | form a regular -s plural | plural of dog; answer `dogs` | dog adds -s | Near duplicate of Q001: mechanical noun replacement |
| Q018 | L03 / FILL_BLANK | select singular/plural | `I see ___.`; no single answer | none is defensible | Ambiguous: no number or source noun |
| Q019 | L02 / SINGLE_CHOICE | form plural of child | answer `children` | child changes to children | Grammar warning: irregular plural belongs to A1-013 |
| Q020 | L02 / MULTIPLE_CHOICE | identify -es forms | valid option set; answers `A,C` | `A and C.` | Explanation warning: no ending rule; targets `boxs/watchs` |

Generated 20; rejected 4; kept 16. Duplicate 1, ambiguity 1, vocabulary 0, grammar 1,
explanation 1. All blueprint capabilities and both regular endings are covered.

## 9. Mastery evidence

The learner transfers the rule when they can form an unseen familiar regular noun after a number,
choose -s versus -es from the taught ending, and correct missing or malformed plurals without being
prompted with the answer form. Irregular noun performance is not evidence for this point.

## B. 完整 Micro Lesson 与 Quick Check（权威源快照）

- Learning Objective：为常见可数名词构成规则复数。
- 自然引入：谈到两个或更多可数事物时，英语名词通常需要复数词尾。
- 核心规则：多数名词加 -s；以 s、x、ch、sh 结尾的常见名词通常加 -es。
- Pattern：`one book → two books · one box → two boxes`
- Examples：
  - `I have three books.` — book 直接加 -s。
  - `We see two cats.` — cat 直接加 -s。
  - `I have two boxes.` — box 以 x 结尾，加 -es。
  - `We see four buses.` — bus 以 s 结尾，加 -es。
- Common Errors：
  - `two cat` → `two cats` — 数量大于一时，可数名词要用复数。
  - `two boxs` → `two boxes` — box 以 x 结尾，要加 -es。
- Memory Tip / Grammar Cat Tip：先看数量，再看名词结尾。
- Quick Checks：
  - **A1-012-MQ01**：“three ___” 应选择哪一个？
    - `A`：`cat`
    - `B`：`cats`
    - `C`：`cates`
    - correctAnswer：`B`
    - explanation：cat 的规则复数直接加 -s。
  - **A1-012-MQ02**：box 的规则复数是什么？
    - `A`：`boxs`
    - `B`：`boxes`
    - `C`：`box`
    - correctAnswer：`B`
    - explanation：以 x 结尾的名词通常加 -es。

## C. 最终保留 Candidate Questions（16 道）

### A1-012-Q001

- lessonCode：`A1-012-L01`
- questionType：`SINGLE_CHOICE`
- prompt：Choose the plural form of “cat”.
- options：
  - `A`：`cat`
  - `B`：`cats`
  - `C`：`cates`
- correctAnswer：`{"optionId":"B"}`
- explanation：cat 是常见规则名词，复数直接在词尾加 -s。
- testedObjective：form cats
- difficulty：`1`
- targetCommonError：`cates`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q002

- lessonCode：`A1-012-L01`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: I have two ___. (book)
- options：—
- correctAnswer：`{"answers":["books"]}`
- explanation：two 表示复数，book 的规则复数是 books。
- testedObjective：form books after two
- difficulty：`1`
- targetCommonError：singular after two
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q003

- lessonCode：`A1-012-L01`
- questionType：`TRUE_FALSE`
- prompt：True or false: “two dogs” uses the correct plural form.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：dog 的规则复数加 -s，two dogs 是正确形式。
- testedObjective：recognize two dogs
- difficulty：`1`
- targetCommonError：missing -s
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q004

- lessonCode：`A1-012-L01`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all phrases with a correct plural noun.
- options：
  - `A`：`two cats`
  - `B`：`three books`
  - `C`：`four boxs`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：cat 和 book 直接加 -s；box 以 x 结尾，复数应为 boxes。
- testedObjective：compare -s with x ending
- difficulty：`1`
- targetCommonError：`boxs`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q005

- lessonCode：`A1-012-L01`
- questionType：`CORRECTION`
- prompt：Correct the noun phrase: three cat
- options：—
- correctAnswer：`{"acceptedAnswers":["three cats"]}`
- explanation：three 表示多个，规则名词 cat 要加 -s。
- testedObjective：repair three cat
- difficulty：`1`
- targetCommonError：missing -s
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q006

- lessonCode：`A1-012-L01`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `books`
  - `have`
  - `two`
  - `I`
  - `.`
- correctAnswer：`{"tokens":["I","have","two","books","."]}`
- explanation：two 后接复数 books，整句按主语、动词、数量和名词排列。
- testedObjective：use two books in a sentence
- difficulty：`1`
- targetCommonError：singular after two
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q007

- lessonCode：`A1-012-L02`
- questionType：`SINGLE_CHOICE`
- prompt：Choose the plural form of “box”.
- options：
  - `A`：`boxs`
  - `B`：`boxes`
  - `C`：`box`
- correctAnswer：`{"optionId":"B"}`
- explanation：box 以 x 结尾，规则复数要加 -es，写成 boxes。
- testedObjective：form boxes
- difficulty：`1`
- targetCommonError：`boxs`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q008

- lessonCode：`A1-012-L02`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: We see two ___. (bus)
- options：—
- correctAnswer：`{"answers":["buses"]}`
- explanation：bus 以 s 结尾，复数加 -es，写成 buses。
- testedObjective：form buses
- difficulty：`1`
- targetCommonError：`buss` / `bus`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q009

- lessonCode：`A1-012-L02`
- questionType：`TRUE_FALSE`
- prompt：True or false: The plural of “dish” is “dishes”.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：dish 以 sh 结尾，规则复数加 -es，得到 dishes。
- testedObjective：recognize dishes
- difficulty：`1`
- targetCommonError：`dishs`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q010

- lessonCode：`A1-012-L02`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all correct regular plural forms.
- options：
  - `A`：`boxes`
  - `B`：`buses`
  - `C`：`watchs`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：box 和 bus 的复数分别是 boxes、buses；watch 应写成 watches。
- testedObjective：select valid -es forms
- difficulty：`2`
- targetCommonError：`watchs`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q011

- lessonCode：`A1-012-L02`
- questionType：`CORRECTION`
- prompt：Correct the noun phrase: two boxs
- options：—
- correctAnswer：`{"acceptedAnswers":["two boxes"]}`
- explanation：box 以 x 结尾，不能只加 -s；正确复数是 boxes。
- testedObjective：repair two boxs
- difficulty：`1`
- targetCommonError：`boxs`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q012

- lessonCode：`A1-012-L03`
- questionType：`SINGLE_CHOICE`
- prompt：I have three ___.
- options：
  - `A`：`book`
  - `B`：`books`
  - `C`：`bookes`
- correctAnswer：`{"optionId":"B"}`
- explanation：three 表示多个，book 的复数形式是 books；I have 是已知的基础句型。
- testedObjective：choose books after three
- difficulty：`1`
- targetCommonError：`bookes`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q013

- lessonCode：`A1-012-L03`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: We see four ___. (bus)
- options：—
- correctAnswer：`{"answers":["buses"]}`
- explanation：four 需要复数名词，bus 以 s 结尾，所以写 buses。
- testedObjective：use buses after four
- difficulty：`2`
- targetCommonError：singular after four
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q014

- lessonCode：`A1-012-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `three`
  - `see`
  - `buses`
  - `We`
  - `.`
- correctAnswer：`{"tokens":["We","see","three","buses","."]}`
- explanation：three 后要用复数 buses，句子按主语、动词、数量和名词排列。
- testedObjective：form We see three buses
- difficulty：`2`
- targetCommonError：wrong plural placement
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q015

- lessonCode：`A1-012-L03`
- questionType：`CORRECTION`
- prompt：Correct the sentence: I have two watchs.
- options：—
- correctAnswer：`{"acceptedAnswers":["I have two watches."]}`
- explanation：watch 以 ch 结尾，复数加 -es，正确形式是 watches。
- testedObjective：repair two watchs
- difficulty：`2`
- targetCommonError：`watchs`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-012-Q016

- lessonCode：`A1-012-L03`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all phrases with the correct plural form.
- options：
  - `A`：`five dogs`
  - `B`：`two dishes`
  - `C`：`three dish`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：dogs 直接加 -s，dishes 加 -es；three 后不能使用单数 dish。
- testedObjective：transfer -s/-es by quantity
- difficulty：`2`
- targetCommonError：`three dish`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

---

# A1-016 Editorial Review

- Specification source：[A1-016.md](A1-016.md)
- Question source：[`curriculum.json`](../../../backend/src/main/resources/content/en/a1/curriculum.json)
- Micro Lesson source：[`micro-lessons.json`](../../../backend/src/main/resources/content/en/a1/micro-lessons.json)

## A. GrammarPoint Specification（现有原文）

# A1-016 Gold Standard Specification — a / an

## 1. Basic info

- Code / level / domain: `A1-016` / A1 / 名词与限定词
- Prerequisite: `A1-012` regular singular/plural nouns
- Editorial lessons: `A1-016-L01` one thing, `L02` choose by first sound, `L03` daily transfer

## 2. Learning objective and prior knowledge

After learning, the learner can choose `a` or `an` before a basic singular countable noun from the
starting sound of the following word. The learner may rely on common nouns, familiar first-person
or plural-subject sentence frames, and the idea of one versus more than one.

## 3. Core rules, scope, and Not Yet

- `a/an` can mean one non-specific person or thing.
- Use `a` before a consonant sound.
- Use `an` before a vowel sound.
- In scope: basic transparent words and short noun phrases such as `a new bag` and `an old dog`.
- Not Yet as formal assessment: `an hour`, `a university`, `a European`, `an honest person`, and
  other spelling/sound exceptions. Learners may be told that sound is ultimately decisive.

Pattern: `a + consonant sound + singular noun`; `an + vowel sound + singular noun`.

## 4. Examples, common errors, and contrast

Examples: `a book`; `a dog`; `a teacher`; `an apple`; `an egg`; `an orange`.

Common errors:

- `a apple` -> `an apple`: apple begins with a vowel sound.
- `an dog` -> `a dog`: dog begins with a consonant sound.
- `I have book.` -> `I have a book.`: a basic singular countable noun needs a determiner.

Contrast: `a` and `an` have the same basic meaning; the next sound changes the form. This lesson
does not contrast them with `the` or teach all cases where articles may be omitted.

## 5. Micro Lesson, memory tip, and Quick Checks

The 60–90 second Micro Lesson shows five transparent sound examples, explains one-item meaning,
and diagnoses `a apple` and the missing article. Grammar Cat tip: “先别急着记例外。听紧跟在
a/an 后面的第一个声音。”

Memory tip: “听开头的声音：元音声音找 an，其他先找 a。”

1. `This is ___ apple.` (`a` / `an`) -> `an`.
2. `I have ___ dog.` (`a` / `an`) -> `a`.

Editorial distractor note: retained Q002 replaces the future quantifier `some` with the explicit UI
label `no article`. The schema accepts ordinary option text, so the item can contrast `a`, `an`, and
the documented missing-article error without importing A1-019.

## 6. Question blueprint

| Capability | Target / actual | Retained codes |
| --- | ---: | --- |
| Rule recognition | 2 / 2 | Q003, Q009 |
| Basic selection | 4 / 4 | Q001, Q002, Q007, Q012 |
| Fill blank | 3 / 3 | Q005, Q008, Q013 |
| Context application | 3 / 3 | Q004, Q010, Q016 |
| Error diagnosis | 2 / 2 | Q011, Q015 |
| Sentence building | 2 / 2 | Q006, Q014 |
| **Total** | **16 / 16** | all three lessons |

## 7. Retained candidate metadata

All rows use `sourceType=AI_DRAFT` and `reviewStatus=REVIEW_REQUIRED`; codes expand to
`A1-016-QNNN`.

| Code | Lesson | Type | Tested objective | Diff. | Target common error |
| --- | --- | --- | --- | ---: | --- |
| Q001 | L01 | SINGLE_CHOICE | choose an before apple | 1 | `a apple` |
| Q002 | L01 | SINGLE_CHOICE | choose a before dog | 1 | `an dog` / missing article |
| Q003 | L01 | TRUE_FALSE | recognize an egg | 1 | `a egg` |
| Q004 | L01 | MULTIPLE_CHOICE | select two sound-safe phrases | 1 | `a apple` |
| Q005 | L01 | FILL_BLANK | supply a before cat in I have | 1 | missing article |
| Q006 | L01 | SENTENCE_ORDER | build I have a book | 1 | missing/misplaced a |
| Q007 | L02 | SINGLE_CHOICE | choose an before animal | 1 | `a animal` |
| Q008 | L02 | FILL_BLANK | supply an before orange | 1 | `a orange` |
| Q009 | L02 | TRUE_FALSE | recognize a teacher | 1 | `an teacher` |
| Q010 | L02 | MULTIPLE_CHOICE | apply both sound groups | 2 | `an teacher` |
| Q011 | L02 | CORRECTION | repair a apple | 1 | `a apple` |
| Q012 | L03 | SINGLE_CHOICE | use a before teacher | 1 | missing article |
| Q013 | L03 | FILL_BLANK | listen to old before dog | 2 | choosing from noun alone |
| Q014 | L03 | SENTENCE_ORDER | build I have an orange | 1 | misplaced an |
| Q015 | L03 | CORRECTION | repair an dog | 1 | `an dog` |
| Q016 | L03 | SENTENCE_ORDER | build It is a new bag | 2 | choosing from bag, not new |

## 8. Rejected candidates and quality review

All rejected rows are difficulty 1, `AI_DRAFT`, and `REVIEW_REQUIRED`; codes expand to
`A1-016-QNNN` and will not be imported.

| Code | Lesson/type | Tested objective | Candidate and answer | Proposed explanation | Warning / target error |
| --- | --- | --- | --- | --- | --- |
| Q017 | L01 / SINGLE_CHOICE | choose a before dog | `I see ___ dog`; answer `a` | dog begins with /d/ | Near duplicate of Q002: no new reasoning |
| Q018 | L02 / SINGLE_CHOICE | choose by initial letter only | article before an unspecified “u” word; no single answer | u words use a/an | Ambiguous: `umbrella` and `university` begin with different sounds |
| Q019 | L02 / SINGLE_CHOICE | choose article before hour | answer `an` | hour begins with a vowel sound | Grammar warning: explicitly Not Yet |
| Q020 | L02 / SINGLE_CHOICE | choose an before egg | answer `B` (`an`) | `B is correct.` | Explanation warning: omits vowel-sound rule; targets `a egg` |

Generated 20; rejected 4; kept 16. Duplicate 1, ambiguity 1, vocabulary 0, grammar 1,
explanation 1. The product-manager blueprint is covered exactly.

## 9. Mastery evidence

Basic mastery requires choosing `a` before a transparent consonant-sound noun, choosing `an`
before a transparent vowel-sound noun, supplying the article in a short sentence, and correcting
both `a apple` and `an dog`. Adjective phrases such as `an old dog` and `a new bag` are retained as
extended transfer, but they do not determine basic mastery. Exception words are excluded.

## B. 完整 Micro Lesson 与 Quick Check（权威源快照）

- Learning Objective：在基础单数可数名词前，根据后面单词的起始发音正确选择 a 或 an。
- 自然引入：第一次提到一个单数可数事物时，通常在名词前使用 a 或 an。
- 核心规则：辅音音素前用 a，元音音素前用 an；判断依据是发音，不只是字母。
- Pattern：`a + consonant sound · an + vowel sound`
- Examples：
  - `a book` — book 以辅音音素 /b/ 开头。
  - `a dog` — dog 以辅音音素 /d/ 开头。
  - `a teacher` — teacher 以辅音音素 /t/ 开头。
  - `an apple` — apple 以元音音素开头。
  - `an egg` — egg 以元音音素开头。
- Common Errors：
  - `a apple` → `an apple` — apple 的第一个音是元音。
  - `I have book.` → `I have a book.` — 单数可数名词 book 前需要限定词。
- Memory Tip / Grammar Cat Tip：听开头的声音：元音声音找 an，其他先找 a。
- Quick Checks：
  - **A1-016-MQ01**：This is ___ apple.
    - `A`：`a`
    - `B`：`an`
    - correctAnswer：`B`
    - explanation：apple 以元音音素开头，使用 an。
  - **A1-016-MQ02**：I have ___ dog.
    - `A`：`a`
    - `B`：`an`
    - correctAnswer：`A`
    - explanation：dog 以辅音音素 /d/ 开头，使用 a。

## C. 最终保留 Candidate Questions（16 道）

### A1-016-Q001

- lessonCode：`A1-016-L01`
- questionType：`SINGLE_CHOICE`
- prompt：This is ___ apple.
- options：
  - `A`：`a`
  - `B`：`an`
  - `C`：`two`
- correctAnswer：`{"optionId":"B"}`
- explanation：apple 以元音音素开头，单数名词前使用 an。
- testedObjective：choose an before apple
- difficulty：`1`
- targetCommonError：`a apple`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q002

- lessonCode：`A1-016-L01`
- questionType：`SINGLE_CHOICE`
- prompt：I have ___ dog.
- options：
  - `A`：`a`
  - `B`：`an`
  - `C`：`no article`
- correctAnswer：`{"optionId":"A"}`
- explanation：dog 以辅音音素 /d/ 开头，且这里是一个单数可数事物，所以使用 a，不能省略冠词。
- testedObjective：choose a before dog
- difficulty：`1`
- targetCommonError：`an dog` / missing article
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q003

- lessonCode：`A1-016-L01`
- questionType：`TRUE_FALSE`
- prompt：True or false: “an egg” uses the correct article.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：egg 以元音音素开头，因此 an egg 是正确搭配。
- testedObjective：recognize an egg
- difficulty：`1`
- targetCommonError：`a egg`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q004

- lessonCode：`A1-016-L01`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all phrases with the correct article.
- options：
  - `A`：`a book`
  - `B`：`an orange`
  - `C`：`a apple`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：book 以辅音音素开头用 a，orange 以元音音素开头用 an；apple 前也应使用 an。
- testedObjective：select two sound-safe phrases
- difficulty：`1`
- targetCommonError：`a apple`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q005

- lessonCode：`A1-016-L01`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: I have ___ cat.
- options：—
- correctAnswer：`{"answers":["a"]}`
- explanation：cat 以辅音音素 /k/ 开头，单数名词前用 a。
- testedObjective：supply a before cat in I have
- difficulty：`1`
- targetCommonError：missing article
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q006

- lessonCode：`A1-016-L01`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `book`
  - `have`
  - `a`
  - `I`
  - `.`
- correctAnswer：`{"tokens":["I","have","a","book","."]}`
- explanation：单数可数名词 book 前使用 a，并放在名词正前方。
- testedObjective：build I have a book
- difficulty：`1`
- targetCommonError：missing/misplaced a
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q007

- lessonCode：`A1-016-L02`
- questionType：`SINGLE_CHOICE`
- prompt：We see ___ animal.
- options：
  - `A`：`a`
  - `B`：`an`
  - `C`：`two`
- correctAnswer：`{"optionId":"B"}`
- explanation：animal 以元音音素开头，因此使用 an。
- testedObjective：choose an before animal
- difficulty：`1`
- targetCommonError：`a animal`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q008

- lessonCode：`A1-016-L02`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: It is ___ orange.
- options：—
- correctAnswer：`{"answers":["an"]}`
- explanation：orange 以元音音素开头，单数名词前使用 an。
- testedObjective：supply an before orange
- difficulty：`1`
- targetCommonError：`a orange`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q009

- lessonCode：`A1-016-L02`
- questionType：`TRUE_FALSE`
- prompt：True or false: “a teacher” uses the correct article.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：teacher 以辅音音素 /t/ 开头，因此使用 a。
- testedObjective：recognize a teacher
- difficulty：`1`
- targetCommonError：`an teacher`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q010

- lessonCode：`A1-016-L02`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all phrases with the correct article.
- options：
  - `A`：`a bag`
  - `B`：`an egg`
  - `C`：`an teacher`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：bag 前用 a，egg 前用 an；teacher 以辅音音素开头，应写 a teacher。
- testedObjective：apply both sound groups
- difficulty：`2`
- targetCommonError：`an teacher`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q011

- lessonCode：`A1-016-L02`
- questionType：`CORRECTION`
- prompt：Correct the sentence: This is a apple.
- options：—
- correctAnswer：`{"acceptedAnswers":["This is an apple."]}`
- explanation：apple 以元音音素开头，要把 a 改为 an。
- testedObjective：repair a apple
- difficulty：`1`
- targetCommonError：`a apple`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q012

- lessonCode：`A1-016-L03`
- questionType：`SINGLE_CHOICE`
- prompt：We see ___ teacher.
- options：
  - `A`：`a`
  - `B`：`an`
  - `C`：`two`
- correctAnswer：`{"optionId":"A"}`
- explanation：teacher 是单数可数名词，并以辅音音素开头，所以用 a。
- testedObjective：use a before teacher
- difficulty：`1`
- targetCommonError：missing article
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q013

- lessonCode：`A1-016-L03`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: We see ___ old dog.
- options：—
- correctAnswer：`{"answers":["an"]}`
- explanation：冠词后紧接 old，old 以元音音素开头，因此用 an。
- testedObjective：listen to old before dog
- difficulty：`2`
- targetCommonError：choosing from noun alone
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q014

- lessonCode：`A1-016-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `orange`
  - `have`
  - `an`
  - `I`
  - `.`
- correctAnswer：`{"tokens":["I","have","an","orange","."]}`
- explanation：an 放在以元音音素开头的 orange 前，构成 an orange。
- testedObjective：build I have an orange
- difficulty：`1`
- targetCommonError：misplaced an
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q015

- lessonCode：`A1-016-L03`
- questionType：`CORRECTION`
- prompt：Correct the sentence: I have an dog.
- options：—
- correctAnswer：`{"acceptedAnswers":["I have a dog."]}`
- explanation：dog 以辅音音素开头，要把 an 改为 a。
- testedObjective：repair an dog
- difficulty：`1`
- targetCommonError：`an dog`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-016-Q016

- lessonCode：`A1-016-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `bag`
  - `is`
  - `new`
  - `a`
  - `It`
  - `.`
- correctAnswer：`{"tokens":["It","is","a","new","bag","."]}`
- explanation：a 放在以辅音音素开头的 new 前，形成 a new bag。
- testedObjective：build It is a new bag
- difficulty：`2`
- targetCommonError：choosing from bag, not new
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

---

# A1-019 Editorial Review

- Specification source：[A1-019.md](A1-019.md)
- Question source：[`curriculum.json`](../../../backend/src/main/resources/content/en/a1/curriculum.json)
- Micro Lesson source：[`micro-lessons.json`](../../../backend/src/main/resources/content/en/a1/micro-lessons.json)

## A. GrammarPoint Specification（现有原文）

# A1-019 Gold Standard Specification — some / any

## 1. Basic info

- Code / level / domain: `A1-019` / A1 / 名词与限定词
- Prerequisite: `A1-018` countable and uncountable noun basics
- Editorial lessons: `A1-019-L01` affirmative some, `L02` negative/question any, `L03` daily transfer
- Editorial verdict: **BLOCKED — REQUIRES CURRICULUM REDESIGN**
- State guardrail: keep every retained item `AI_DRAFT + REVIEW_REQUIRED`; do not rewrite or approve
  the 16 questions until the learning-order decision is made.

## 2. Learning objective and prior knowledge

After learning, the learner can choose `some` or `any` in clear basic affirmative, negative, and
ordinary yes/no-question contexts. The learner may rely on simple present have/do, basic be, and
familiar countable/uncountable nouns.

## 3. Core rules, scope, and Not Yet

- Basic affirmative statements usually use `some`.
- Basic negative statements usually use `any`.
- Ordinary yes/no questions usually use `any`.
- In scope: explicit sentence polarity with books, food, family, pets, and classroom objects.
- Not Yet: offer/request uses such as `Would you like some...?` and `Can I have some...?`, free-
  choice `any`, emphatic meanings, and contexts where speaker expectation changes the choice.

Pattern: `positive + some + noun`; `negative/question + any + noun`.

## 4. Examples, common errors, and contrast

Examples: `I have some books.`; `We have some milk.`; `I don't have any milk.`;
`We don't have any bread.`; `Do you have any questions?`; `Are there any students?`

Common errors:

- `I don't have some brothers.` -> `I don't have any brothers.`
- `Do you have some questions?` -> `Do you have any questions?` for an ordinary neutral question.
- `We have any apples.` -> `We have some apples.` under the basic affirmative rule.

Contrast: first identify affirmative, negative, or ordinary question form. Do not use offer/request
examples in assessment because `some` may be natural there.

## 5. Micro Lesson, memory tip, and Quick Checks

The 60–90 second Micro Lesson shows one affirmative, one negative, and one question, then repairs
the first two errors. Grammar Cat tip: “先判断句子是肯定、否定，还是普通疑问句，再选词。”

Memory tip: “肯定 some，疑问和否定先想到 any。”

1. `There are ___ apples on the table.` (`some` / `any` / `an`) -> `some`.
2. `Are there ___ shops near here?` (`some` / `any` / `a`) -> `any`.

## 6. Question blueprint

| Capability | Count | Retained codes |
| --- | ---: | --- |
| Rule recognition | 2 | Q003, Q010 |
| Affirmative | 3 | Q001, Q002, Q004 |
| Negative | 3 | Q007, Q008, Q011 |
| Ordinary question | 3 | Q009, Q012, Q014 |
| Context application | 2 | Q006, Q013 |
| Correction | 3 | Q005, Q015, Q016 |
| **Total** | **16** | all three lessons |

## 7. Retained candidate metadata

All rows use `sourceType=AI_DRAFT` and `reviewStatus=REVIEW_REQUIRED`; codes expand to
`A1-019-QNNN`.

| Code | Lesson | Type | Tested objective | Diff. | Target common error |
| --- | --- | --- | --- | ---: | --- |
| Q001 | L01 | SINGLE_CHOICE | choose some in affirmative | 1 | affirmative any |
| Q002 | L01 | FILL_BLANK | supply some with milk | 1 | affirmative any |
| Q003 | L01 | TRUE_FALSE | recognize affirmative rule | 1 | polarity confusion |
| Q004 | L01 | MULTIPLE_CHOICE | identify two clear affirmatives | 1 | affirmative any |
| Q005 | L01 | CORRECTION | repair have any apples | 1 | affirmative any |
| Q006 | L01 | SENTENCE_ORDER | form We have some milk | 1 | misplaced quantifier |
| Q007 | L02 | SINGLE_CHOICE | choose any in negative | 1 | negative some |
| Q008 | L02 | FILL_BLANK | supply any after don't | 1 | negative some |
| Q009 | L02 | SINGLE_CHOICE | choose any in neutral question | 1 | question some |
| Q010 | L02 | TRUE_FALSE | recognize negative rule | 1 | polarity confusion |
| Q011 | L02 | MULTIPLE_CHOICE | distinguish negative/question | 2 | negative some |
| Q012 | L03 | SINGLE_CHOICE | apply any in there-question | 1 | question some |
| Q013 | L03 | FILL_BLANK | transfer some to lunch context | 1 | affirmative any |
| Q014 | L03 | SENTENCE_ORDER | form Do you have any questions | 2 | misplaced any |
| Q015 | L03 | CORRECTION | repair don't have some | 2 | negative some |
| Q016 | L03 | CORRECTION | repair explicitly neutral question | 2 | question some |

## 8. Rejected candidates and quality review

All rejected rows are difficulty 1, `AI_DRAFT`, and `REVIEW_REQUIRED`; codes expand to
`A1-019-QNNN` and will not be imported.

| Code | Lesson/type | Tested objective | Candidate and answer | Proposed explanation | Warning / target error |
| --- | --- | --- | --- | --- | --- |
| Q017 | L01 / SINGLE_CHOICE | choose some in affirmative | replace books with pens in Q001; answer `some` | affirmative uses some | Near duplicate: only the noun changes |
| Q018 | L03 / SINGLE_CHOICE | choose in a question | `Do you want ___ water?`; `some/any` depend on intent | either may occur | Ambiguous: neutral question versus offer |
| Q019 | L03 / SINGLE_CHOICE | recognize offer use | `Would you like ___ tea?`; answer `some` | offers often use some | Grammar warning: offer usage is Not Yet |
| Q020 | L02 / CORRECTION | repair negative some | answer uses `any` | `Use any.` | Explanation warning: does not identify negative polarity |

Generated 20; rejected 4; kept 16. Duplicate 1, ambiguity 1, vocabulary 0, grammar 1,
explanation 1. Every retained item has a polarity cue, preventing some/any ambiguity.

## 9. Mastery evidence

The learner transfers the rule when they first identify polarity, then select or produce some/any
with a new familiar noun, and can explain and correct both a negative-with-some and an ordinary-
question-with-some error. Offer/request performance is excluded from this mastery judgment.

## 10. Dependency redesign options (proposal only)

The present full scope assumes affirmative `have`, simple-present negatives with `don't`,
`Do you have...?`, and `Are there...?`. `A1-018` alone does not supply those forms. No option below
is implemented in the prerequisite DAG or questions during this revision pass.

### Option A — keep the stable code and move the learning node later

Recommended prerequisite set for the current full scope: `A1-018`, `A1-021`, and `A1-027`.
`A1-027` transitively supplies A1-024–026; A1-021 supplies There is/are question forms.

- Advantage: preserves one coherent some/any contrast and all 16 question intentions.
- Disadvantage: A1-019 is learned substantially later than its stable code suggests.
- DAG impact: add edges from A1-021 and A1-027 to A1-019; first remove `any` as assumed knowledge
  from A1-021 examples so the two nodes do not depend on each other.
- Lesson/question impact: wording can largely remain, but all items need re-review after the move.
- Learning Path impact: schedule A1-019 after both question systems, independent of numeric code.

### Option B — split the teaching scope

Keep A1-019 for affirmative `some` after A1-018; move negative `any` after A1-026 and question
`any` after A1-021/A1-027, either as later lessons or a separate GrammarPoint decided by product.

- Advantage: introduces quantity language earlier while preserving prerequisite safety.
- Disadvantage: weakens the current one-lesson contrast and requires lesson/question reassignment.
- DAG impact: the affirmative node can retain A1-018; later portions gain their own dependencies.
- Lesson/question impact: Q007–Q012 and Q014–Q016 cannot remain in the early mastery set unchanged.
- Learning Path impact: learners revisit the lexical pair across multiple later checkpoints.

### Option C — defer the entire contrast and simplify adjacent nodes

Keep A1-019 stable but unavailable until a later quantifier module; teach A1-018 without `some`,
and teach A1-021 questions using explicit numbers or bare plural examples instead of `any`.

- Advantage: cleanest dependency boundary and no cyclic semantic assumption.
- Disadvantage: delays highly useful A1 quantity language and requires adjacent-content revision.
- DAG impact: no immediate edge decision; product defines the later module placement.
- Lesson/question impact: all 16 candidates stay frozen for later review.
- Learning Path impact: A1-019 is omitted from the early path without changing its stable ID.

## B. 完整 Micro Lesson 与 Quick Check（权威源快照）

- Learning Objective：在基础肯定句、否定句和疑问句中选择 some 或 any。
- 自然引入：some 和 any 都能表达不确定数量，但它们最常出现的句型不同。
- 核心规则：基础用法中，肯定句常用 some；否定句和一般疑问句常用 any。
- Pattern：`positive: some · negative/question: any`
- Examples：
  - `We have some milk.` — 肯定句使用 some。
  - `I don't have any bread.` — 否定句使用 any。
  - `Do you have any water?` — 一般疑问句使用 any。
- Common Errors：
  - `I don't have some brothers.` → `I don't have any brothers.` — 基础否定句使用 any。
  - `Do you have some questions?` → `Do you have any questions?` — 普通一般疑问句使用 any。
- Memory Tip / Grammar Cat Tip：肯定 some，疑问和否定先想到 any。
- Quick Checks：
  - **A1-019-MQ01**：There are ___ apples on the table.
    - `A`：`some`
    - `B`：`any`
    - `C`：`an`
    - correctAnswer：`A`
    - explanation：这是肯定句，基础用法选择 some。
  - **A1-019-MQ02**：Are there ___ shops near here?
    - `A`：`some`
    - `B`：`any`
    - `C`：`a`
    - correctAnswer：`B`
    - explanation：一般疑问句中使用 any。

## C. 最终保留 Candidate Questions（16 道）

### A1-019-Q001

- lessonCode：`A1-019-L01`
- questionType：`SINGLE_CHOICE`
- prompt：I have ___ books in my bag.
- options：
  - `A`：`some`
  - `B`：`any`
  - `C`：`an`
- correctAnswer：`{"optionId":"A"}`
- explanation：这是基础肯定句，表达不确定数量时通常使用 some。
- testedObjective：choose some in affirmative
- difficulty：`1`
- targetCommonError：affirmative any
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q002

- lessonCode：`A1-019-L01`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: There is ___ milk in the fridge.
- options：—
- correctAnswer：`{"answers":["some"]}`
- explanation：这是肯定句，milk 的数量不确定，因此使用 some。
- testedObjective：supply some with milk
- difficulty：`1`
- targetCommonError：affirmative any
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q003

- lessonCode：`A1-019-L01`
- questionType：`TRUE_FALSE`
- prompt：True or false: “I have some apples” is correct in this lesson.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：肯定句中通常使用 some，所以这个句子符合基础规则。
- testedObjective：recognize affirmative rule
- difficulty：`1`
- targetCommonError：polarity confusion
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q004

- lessonCode：`A1-019-L01`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all sentences with correct use of “some”.
- options：
  - `A`：`We have some bread.`
  - `B`：`Anna has some books.`
  - `C`：`I have any milk.`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：A 和 B 都是肯定句，通常用 some；C 按本课基础规则应使用 some。
- testedObjective：identify two clear affirmatives
- difficulty：`1`
- targetCommonError：affirmative any
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q005

- lessonCode：`A1-019-L01`
- questionType：`CORRECTION`
- prompt：Correct the sentence: We have any apples.
- options：—
- correctAnswer：`{"acceptedAnswers":["We have some apples."]}`
- explanation：这是基础肯定句，通常把 any 改为 some。
- testedObjective：repair have any apples
- difficulty：`1`
- targetCommonError：affirmative any
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q006

- lessonCode：`A1-019-L01`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `some`
  - `have`
  - `milk`
  - `We`
  - `.`
- correctAnswer：`{"tokens":["We","have","some","milk","."]}`
- explanation：肯定句中 some 放在名词 milk 前，表示不确定数量。
- testedObjective：form We have some milk
- difficulty：`1`
- targetCommonError：misplaced quantifier
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q007

- lessonCode：`A1-019-L02`
- questionType：`SINGLE_CHOICE`
- prompt：I don't have ___ brothers.
- options：
  - `A`：`some`
  - `B`：`any`
  - `C`：`an`
- correctAnswer：`{"optionId":"B"}`
- explanation：这是基础否定句，表达没有时通常使用 any。
- testedObjective：choose any in negative
- difficulty：`1`
- targetCommonError：negative some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q008

- lessonCode：`A1-019-L02`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: I don't have ___ milk.
- options：—
- correctAnswer：`{"answers":["any"]}`
- explanation：don't have 构成否定句，基础用法选择 any。
- testedObjective：supply any after don't
- difficulty：`1`
- targetCommonError：negative some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q009

- lessonCode：`A1-019-L02`
- questionType：`SINGLE_CHOICE`
- prompt：Do you have ___ questions?
- options：
  - `A`：`some`
  - `B`：`any`
  - `C`：`a`
- correctAnswer：`{"optionId":"B"}`
- explanation：这是普通一般疑问句，基础规则通常使用 any。
- testedObjective：choose any in neutral question
- difficulty：`1`
- targetCommonError：question some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q010

- lessonCode：`A1-019-L02`
- questionType：`TRUE_FALSE`
- prompt：True or false: “We don't have any bread” is correct in this lesson.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：否定句中通常使用 any，所以这个句子符合基础规则。
- testedObjective：recognize negative rule
- difficulty：`1`
- targetCommonError：polarity confusion
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q011

- lessonCode：`A1-019-L02`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all sentences that correctly use “any”.
- options：
  - `A`：`I don't have any pets.`
  - `B`：`Do you have any sisters?`
  - `C`：`We don't have some milk.`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：A 是否定句，B 是一般疑问句，都用 any；C 按基础规则应改用 any。
- testedObjective：distinguish negative/question
- difficulty：`2`
- targetCommonError：negative some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q012

- lessonCode：`A1-019-L03`
- questionType：`SINGLE_CHOICE`
- prompt：Are there ___ students in the classroom?
- options：
  - `A`：`some`
  - `B`：`any`
  - `C`：`an`
- correctAnswer：`{"optionId":"B"}`
- explanation：这是普通一般疑问句，询问是否有学生时通常使用 any。
- testedObjective：apply any in there-question
- difficulty：`1`
- targetCommonError：question some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q013

- lessonCode：`A1-019-L03`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: They have ___ apples for lunch.
- options：—
- correctAnswer：`{"answers":["some"]}`
- explanation：这是肯定句，表示若干苹果时使用 some。
- testedObjective：transfer some to lunch context
- difficulty：`1`
- targetCommonError：affirmative any
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q014

- lessonCode：`A1-019-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `questions`
  - `you`
  - `any`
  - `Do`
  - `have`
  - `?`
- correctAnswer：`{"tokens":["Do","you","have","any","questions","?"]}`
- explanation：一般疑问句中 any 放在复数名词 questions 前。
- testedObjective：form Do you have any questions
- difficulty：`2`
- targetCommonError：misplaced any
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q015

- lessonCode：`A1-019-L03`
- questionType：`CORRECTION`
- prompt：Correct the sentence: I don't have some brothers.
- options：—
- correctAnswer：`{"acceptedAnswers":["I don't have any brothers."]}`
- explanation：这是基础否定句，要把 some 改为 any。
- testedObjective：repair don't have some
- difficulty：`2`
- targetCommonError：negative some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-019-Q016

- lessonCode：`A1-019-L03`
- questionType：`CORRECTION`
- prompt：A teacher asks a neutral question. Correct it: Do you have some questions?
- options：—
- correctAnswer：`{"acceptedAnswers":["Do you have any questions?"]}`
- explanation：这是普通一般疑问句，按本课基础规则把 some 改为 any。
- testedObjective：repair explicitly neutral question
- difficulty：`2`
- targetCommonError：question some
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

---

# A1-020 Editorial Review

- Specification source：[A1-020.md](A1-020.md)
- Question source：[`curriculum.json`](../../../backend/src/main/resources/content/en/a1/curriculum.json)
- Micro Lesson source：[`micro-lessons.json`](../../../backend/src/main/resources/content/en/a1/micro-lessons.json)

## A. GrammarPoint Specification（现有原文）

# A1-020 Gold Standard Specification — There is / There are (Affirmative)

## 1. Basic info

- Code / level / domain: `A1-020` / A1 / 语法基础
- Prerequisites: `A1-003` be affirmative, `A1-012` regular plurals, and `A1-016` a/an
- Editorial lessons: `A1-020-L01` singular existence, `L02` plural existence, `L03` place transfer

## 2. Learning objective and prior knowledge

After learning, the learner can choose and form `There is` or `There are` in a basic affirmative
existence sentence according to the number of the following noun. The learner may rely on is/are,
singular/plural recognition, a/an, numbers, and simple place phrases.

## 3. Core rules, scope, and Not Yet

- Use `There is + singular noun` for one thing.
- Use `There are + plural noun` for two or more things.
- Look at whether the thing after There is/are is one thing or more than one.
- In scope: affirmative descriptions of rooms, desks, parks, gardens, and pictures.
- Not Yet: negative forms, yes/no or wh-questions, short answers, contractions, and complex lists.
  A1-021 owns negative and question forms.

Pattern: `There is + a/an + singular noun + place`; `There are + number + plural noun + place`.

## 4. Examples, common errors, and contrast

Examples: `There is a book on the desk.`; `There is a cat in the garden.`;
`There is an apple in the bag.`; `There are two books on the desk.`;
`There are two chairs in the room.`; `There are five students in the class.`

Common errors:

- `There is three books.` -> `There are three books.`: three books is plural.
- `There are a dog outside.` -> `There is a dog outside.`: a dog is singular.
- `There two trees are.` -> `There are two trees.`: keep There + be together.

Contrast: `There is/are` introduces what exists; `It is/They are` identifies or describes something
already in focus. Only the number contrast is assessed here.

## 5. Micro Lesson, memory tip, and Quick Checks

The 60–90 second Micro Lesson pairs two singular and two plural scenes, then repairs the first two
errors. Grammar Cat tip: “看 There is/are 后面说的是一个还是多个。”

Memory tip: “一个用 There is，两个或更多用 There are。”

1. `___ a park near my home.` (`There is` / `There are` / `They are`) -> `There is`.
2. Choose the sentence meaning “有两扇窗” -> `There are two windows.`

## 6. Question blueprint

| Capability | Count | Retained codes |
| --- | ---: | --- |
| Singular/plural recognition | 3 | Q003, Q011, Q015 |
| There is/are selection | 4 | Q001, Q004, Q007, Q012 |
| Sentence completion | 3 | Q002, Q008, Q013 |
| Word order | 3 | Q010, Q014, Q016 |
| Context discrimination | 1 | Q005 |
| Correction | 2 | Q006, Q009 |
| **Total** | **16** | all three lessons |

## 7. Retained candidate metadata

All rows use `sourceType=AI_DRAFT` and `reviewStatus=REVIEW_REQUIRED`; codes expand to
`A1-020-QNNN`.

| Code | Lesson | Type | Tested objective | Diff. | Target common error |
| --- | --- | --- | --- | ---: | --- |
| Q001 | L01 | SINGLE_CHOICE | select singular existence sentence | 1 | are + singular |
| Q002 | L01 | FILL_BLANK | supply is before a cat | 1 | are + singular |
| Q003 | L01 | TRUE_FALSE | state singular rule | 1 | number mismatch |
| Q004 | L01 | SINGLE_CHOICE | select is with an apple | 1 | inversion / are + singular |
| Q005 | L01 | MULTIPLE_CHOICE | identify two singular sentences | 2 | are + a chair |
| Q006 | L01 | CORRECTION | repair are + a dog | 1 | `There are a dog` |
| Q007 | L02 | SINGLE_CHOICE | select are before two chairs | 1 | is + plural |
| Q008 | L02 | FILL_BLANK | supply are before three books | 1 | is + plural |
| Q009 | L02 | CORRECTION | repair is + two bags | 1 | `There is two bags` |
| Q010 | L02 | SENTENCE_ORDER | build There are two trees | 1 | separated There/are |
| Q011 | L02 | TRUE_FALSE | state plural rule | 2 | number mismatch |
| Q012 | L03 | SINGLE_CHOICE | transfer singular rule to room | 1 | wrong quantity/form |
| Q013 | L03 | FILL_BLANK | transfer are to classroom | 2 | is + five students |
| Q014 | L03 | SENTENCE_ORDER | build plural place sentence | 2 | word order |
| Q015 | L03 | MULTIPLE_CHOICE | identify two plural sentences | 2 | is + three pens |
| Q016 | L03 | SENTENCE_ORDER | build singular place sentence | 2 | word order |

## 8. Rejected candidates and quality review

All rejected rows are difficulty 1, `AI_DRAFT`, and `REVIEW_REQUIRED`; codes expand to
`A1-020-QNNN` and will not be imported.

| Code | Lesson/type | Tested objective | Candidate and answer | Proposed explanation | Warning / target error |
| --- | --- | --- | --- | --- | --- |
| Q017 | L01 / SINGLE_CHOICE | select is for one thing | replace book with dog in Q001; answer `There is` | a dog is singular | Near duplicate: mechanical noun replacement |
| Q018 | L03 / FILL_BLANK | choose is/are by number | `There ___ fish in the pond.`; no single answer | fish takes is/are | Ambiguous: fish may be singular or plural |
| Q019 | L02 / SINGLE_CHOICE | form an existence question | `Are there any books?`; answer is the question form | are moves before there | Grammar warning: questions belong to A1-021 |
| Q020 | L02 / CORRECTION | repair is + plural | corrected answer uses `There are` | `Use are.` | Explanation warning: does not connect are to plural number |

Generated 20; rejected 4; kept 16. Duplicate 1, ambiguity 1, vocabulary 0, grammar 1,
explanation 1. All retained items are affirmative and every noun has explicit number.

## 9. Mastery evidence

The learner transfers the rule when they choose is/are from a new scene's noun number, produce a
complete affirmative existence sentence, order There + be correctly, and repair both singular and
plural agreement errors. Negative or question performance is excluded until A1-021.

## B. 完整 Micro Lesson 与 Quick Check（权威源快照）

- Learning Objective：用 There is 和 There are 表达某处存在的人或事物。
- 自然引入：描述房间、街道或图片中“有什么”时，可以从 There is 或 There are 开始。
- 核心规则：后接一个单数事物时用 There is；后接两个或更多复数事物时用 There are。
- Pattern：`There is + singular · There are + plural`
- Examples：
  - `There is a book on the desk.` — a book 是单数。
  - `There is a cat in the garden.` — a cat 是单数。
  - `There are two books on the desk.` — two books 是复数。
  - `There are two chairs in the room.` — two chairs 是复数。
- Common Errors：
  - `There is three books.` → `There are three books.` — three books 是复数。
  - `There are a dog outside.` → `There is a dog outside.` — a dog 是单数。
- Memory Tip / Grammar Cat Tip：看 There is/are 后面说的是一个还是多个。
- Quick Checks：
  - **A1-020-MQ01**：___ a park near my home.
    - `A`：`There is`
    - `B`：`There are`
    - `C`：`They are`
    - correctAnswer：`A`
    - explanation：a park 是单数，使用 There is。
  - **A1-020-MQ02**：请选择能够正确表达“有两扇窗”的句子。
    - `A`：`There are two windows.`
    - `B`：`There is two windows.`
    - `C`：`There two windows are.`
    - correctAnswer：`A`
    - explanation：two windows 是复数，使用 There are。

## C. 最终保留 Candidate Questions（16 道）

### A1-020-Q001

- lessonCode：`A1-020-L01`
- questionType：`SINGLE_CHOICE`
- prompt：Choose the correct sentence about one book on a desk.
- options：
  - `A`：`There is a book on the desk.`
  - `B`：`There are a book on the desk.`
  - `C`：`There is two books on the desk.`
- correctAnswer：`{"optionId":"A"}`
- explanation：a book 是单数，所以存在表达使用 There is。
- testedObjective：select singular existence sentence
- difficulty：`1`
- targetCommonError：are + singular
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q002

- lessonCode：`A1-020-L01`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: There ___ a cat in the garden.
- options：—
- correctAnswer：`{"answers":["is"]}`
- explanation：a cat 是单数，因此使用 There is。
- testedObjective：supply is before a cat
- difficulty：`1`
- targetCommonError：are + singular
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q003

- lessonCode：`A1-020-L01`
- questionType：`TRUE_FALSE`
- prompt：True or false: We use “There is” before a singular noun.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：There is 后接一个单数事物，这是本课的基础规则。
- testedObjective：state singular rule
- difficulty：`1`
- targetCommonError：number mismatch
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q004

- lessonCode：`A1-020-L01`
- questionType：`SINGLE_CHOICE`
- prompt：Choose the correct sentence about one apple.
- options：
  - `A`：`There is an apple in the bag.`
  - `B`：`There are an apple in the bag.`
  - `C`：`There an apple is in the bag.`
- correctAnswer：`{"optionId":"A"}`
- explanation：an apple 是单数，所以用 There is，并保持正常语序。
- testedObjective：select is with an apple
- difficulty：`1`
- targetCommonError：inversion / are + singular
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q005

- lessonCode：`A1-020-L01`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all correct sentences about one thing.
- options：
  - `A`：`There is a desk in the room.`
  - `B`：`There is an apple on the table.`
  - `C`：`There are a chair by the door.`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：A 和 B 都描述一个事物，所以用 There is；C 的 a chair 也应搭配 There is。
- testedObjective：identify two singular sentences
- difficulty：`2`
- targetCommonError：are + a chair
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q006

- lessonCode：`A1-020-L01`
- questionType：`CORRECTION`
- prompt：Correct the sentence: There are a dog outside.
- options：—
- correctAnswer：`{"acceptedAnswers":["There is a dog outside."]}`
- explanation：a dog 是单数，肯定存在句要使用 There is。
- testedObjective：repair are + a dog
- difficulty：`1`
- targetCommonError：`There are a dog`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q007

- lessonCode：`A1-020-L02`
- questionType：`SINGLE_CHOICE`
- prompt：___ two chairs by the window.
- options：
  - `A`：`There is`
  - `B`：`There are`
  - `C`：`It is`
- correctAnswer：`{"optionId":"B"}`
- explanation：two chairs 是复数，所以使用 There are。
- testedObjective：select are before two chairs
- difficulty：`1`
- targetCommonError：is + plural
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q008

- lessonCode：`A1-020-L02`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: There ___ three books on the shelf.
- options：—
- correctAnswer：`{"answers":["are"]}`
- explanation：three books 是复数，因此使用 There are。
- testedObjective：supply are before three books
- difficulty：`1`
- targetCommonError：is + plural
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q009

- lessonCode：`A1-020-L02`
- questionType：`CORRECTION`
- prompt：Correct the sentence: There is two bags here.
- options：—
- correctAnswer：`{"acceptedAnswers":["There are two bags here."]}`
- explanation：two bags 是复数，所以要把 There is 改为 There are。
- testedObjective：repair is + two bags
- difficulty：`1`
- targetCommonError：`There is two bags`
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q010

- lessonCode：`A1-020-L02`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `two`
  - `There`
  - `trees`
  - `are`
  - `.`
- correctAnswer：`{"tokens":["There","are","two","trees","."]}`
- explanation：复数存在句按 There + are + 复数名词排列。
- testedObjective：build There are two trees
- difficulty：`1`
- targetCommonError：separated There/are
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q011

- lessonCode：`A1-020-L02`
- questionType：`TRUE_FALSE`
- prompt：True or false: We use “There are” before a plural noun.
- options：
  - `true`：`True`
  - `false`：`False`
- correctAnswer：`{"value":true}`
- explanation：There are 后接两个或更多事物，这是复数存在表达。
- testedObjective：state plural rule
- difficulty：`2`
- targetCommonError：number mismatch
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q012

- lessonCode：`A1-020-L03`
- questionType：`SINGLE_CHOICE`
- prompt：You see one bed in a room. Choose the matching sentence.
- options：
  - `A`：`There is a bed in the room.`
  - `B`：`There are a bed in the room.`
  - `C`：`There are two beds in the room.`
- correctAnswer：`{"optionId":"A"}`
- explanation：one bed 是单数，只有 A 使用 There is 并保持数量一致。
- testedObjective：transfer singular rule to room
- difficulty：`1`
- targetCommonError：wrong quantity/form
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q013

- lessonCode：`A1-020-L03`
- questionType：`FILL_BLANK`
- prompt：Fill in the blank: There ___ five students in the class.
- options：—
- correctAnswer：`{"answers":["are"]}`
- explanation：five students 是复数，因此使用 There are。
- testedObjective：transfer are to classroom
- difficulty：`2`
- targetCommonError：is + five students
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q014

- lessonCode：`A1-020-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `park`
  - `are`
  - `two`
  - `the`
  - `in`
  - `trees`
  - `There`
  - `.`
- correctAnswer：`{"tokens":["There","are","two","trees","in","the","park","."]}`
- explanation：先用 There are 引出复数 two trees，再补充地点。
- testedObjective：build plural place sentence
- difficulty：`1`
- targetCommonError：word order
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q015

- lessonCode：`A1-020-L03`
- questionType：`MULTIPLE_CHOICE`
- prompt：Select all correct sentences about several things.
- options：
  - `A`：`There are two cats outside.`
  - `B`：`There are four windows in the room.`
  - `C`：`There is three pens on the desk.`
- correctAnswer：`{"optionIds":["A","B"]}`
- explanation：A 和 B 的名词都是复数，正确使用 There are；C 应改为 There are。
- testedObjective：identify two plural sentences
- difficulty：`2`
- targetCommonError：is + three pens
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`

### A1-020-Q016

- lessonCode：`A1-020-L03`
- questionType：`SENTENCE_ORDER`
- prompt：Put the words in the correct order.
- options：
  - `near`
  - `a`
  - `There`
  - `home`
  - `park`
  - `is`
  - `my`
  - `.`
- correctAnswer：`{"tokens":["There","is","a","park","near","my","home","."]}`
- explanation：单数存在句先用 There is，再接 a park 和地点信息。
- testedObjective：build singular place sentence
- difficulty：`2`
- targetCommonError：word order
- sourceType：`AI_DRAFT`
- reviewStatus：`REVIEW_REQUIRED`
