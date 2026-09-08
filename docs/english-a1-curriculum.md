# English A1 Grammar Tree Curriculum

## 1. 范围与权威来源

阶段 8A 只落地 English A1。知识点编号、名称和前置关系来自
`GrammarAgent_English_A1-B2_Grammar_Tree_Curriculum_v1.docx` 的 A1 表格；A2、B1、B2
没有导入数据库，也没有出现在客户端课程树中。可执行内容源为
`backend/src/main/resources/content/en/a1/curriculum.json`，当前版本为 `en-a1-v1`。

## 2. 稳定编号策略

`grammar_points.code` 是跨环境稳定内容标识，A1 固定使用 `A1-001` 至 `A1-045`。
数据库自增 `id` 只用于内部外键和 API 资源定位，不承担内容版本标识。Lesson 和 Question
当前以“父级稳定标识 + sort_order”进行幂等更新。

## 3. 七个 A1 学习领域

| 顺序 | 领域 | 知识点数 | Lesson 数 |
| --- | --- | ---: | ---: |
| 1 | 语法基础 | 7 | 21 |
| 2 | 代词与所属 | 5 | 15 |
| 3 | 名词与限定词 | 7 | 21 |
| 4 | 时态与体 | 6 | 18 |
| 5 | 疑问与否定 | 9 | 27 |
| 6 | 情态与造句 | 4 | 12 |
| 7 | 描述、比较与连接 | 7 | 21 |

领域是面向学习者的 Chapter 分组；真正的先修关系由数据库
`grammar_point_prerequisites` 表表达，是跨领域的有向无环图。

## 4. 45 个知识点清单

| 编号 | 学习领域 | 知识点 | 前置编号 |
| --- | --- | --- | --- |
| A1-001 | 语法基础 | 基础句子骨架：Subject + Verb (+ Object/Complement) | — |
| A1-002 | 代词与所属 | 主格人称代词：I / you / he / she / it / we / they | A1-001 |
| A1-003 | 语法基础 | be 动词肯定句：am / is / are | A1-002 |
| A1-004 | 语法基础 | be 动词缩写：I'm / you're / he's / we're 等 | A1-003 |
| A1-005 | 语法基础 | be 动词否定句：am not / isn't / aren't | A1-003 |
| A1-006 | 疑问与否定 | be 动词一般疑问句与简短回答 | A1-003 |
| A1-007 | 疑问与否定 | 基础疑问词：what / who / where / when / how | A1-001 |
| A1-008 | 疑问与否定 | be 动词特殊疑问句 | A1-006, A1-007 |
| A1-009 | 代词与所属 | 宾格人称代词：me / you / him / her / it / us / them | A1-002 |
| A1-010 | 代词与所属 | 形容词性物主代词：my / your / his / her / our / their | A1-002 |
| A1-011 | 代词与所属 | 名词性物主代词：mine / yours / his / hers / ours / theirs | A1-010 |
| A1-012 | 名词与限定词 | 名词单复数：-s / -es 基础 | A1-001 |
| A1-013 | 名词与限定词 | 常见不规则复数：men / children / feet 等 | A1-012 |
| A1-014 | 代词与所属 | 名词所有格：Tom's / my parents' | A1-012 |
| A1-015 | 名词与限定词 | 指示词：this / that / these / those | A1-012 |
| A1-016 | 名词与限定词 | 不定冠词：a / an | A1-012 |
| A1-017 | 名词与限定词 | 定冠词 the：已知、唯一、再次提及 | A1-016 |
| A1-018 | 名词与限定词 | 可数与不可数名词入门 | A1-012 |
| A1-019 | 名词与限定词 | some / any 基础用法 | A1-018 |
| A1-020 | 语法基础 | There is / There are 肯定句 | A1-003, A1-012 |
| A1-021 | 疑问与否定 | There is / are 的否定句与疑问句 | A1-020 |
| A1-022 | 语法基础 | have / has got 肯定句 | A1-002 |
| A1-023 | 疑问与否定 | have / has got 否定句与疑问句 | A1-022 |
| A1-024 | 时态与体 | 一般现在时：肯定句与基本用途 | A1-001, A1-002 |
| A1-025 | 时态与体 | 一般现在时第三人称单数：-s / -es | A1-024 |
| A1-026 | 疑问与否定 | 一般现在时否定句：don't / doesn't | A1-024, A1-025 |
| A1-027 | 疑问与否定 | 一般现在时一般疑问句：Do / Does | A1-026 |
| A1-028 | 疑问与否定 | 一般现在时特殊疑问句 | A1-007, A1-027 |
| A1-029 | 时态与体 | 频率副词：always / usually / often / sometimes / never | A1-024 |
| A1-030 | 时态与体 | 基础副词位置：be 后、实义动词前、句末时间/地点 | A1-003, A1-024, A1-029 |
| A1-031 | 时态与体 | 现在进行时：be + V-ing 肯定句 | A1-003 |
| A1-032 | 疑问与否定 | 现在进行时否定句与疑问句 | A1-031 |
| A1-033 | 时态与体 | 一般现在时 vs 现在进行时 | A1-024, A1-031 |
| A1-034 | 情态与造句 | can / can't：能力 | A1-001 |
| A1-035 | 情态与造句 | can：许可、请求与简单回应 | A1-034 |
| A1-036 | 情态与造句 | 祈使句：肯定与否定命令 | A1-001 |
| A1-037 | 情态与造句 | Let's + 动词：建议 | A1-036 |
| A1-038 | 描述、比较与连接 | 形容词位置：be 后与名词前 | A1-003, A1-012 |
| A1-039 | 描述、比较与连接 | 方式副词：slowly / carefully / well 等 | A1-038 |
| A1-040 | 描述、比较与连接 | 地点介词：in / on / under / next to / between / behind | A1-012 |
| A1-041 | 描述、比较与连接 | 时间介词：at / on / in | A1-024 |
| A1-042 | 描述、比较与连接 | 基础连接词：and / but / or / because | A1-001 |
| A1-043 | 描述、比较与连接 | 形容词比较级：-er / more | A1-038 |
| A1-044 | 描述、比较与连接 | 形容词最高级：-est / most | A1-043 |
| A1-045 | 语法基础 | 基础语序整合：Subject + Verb + Object + Place + Time | A1-024, A1-030, A1-040, A1-041 |

## 5. 前置 DAG

当前 A1 图包含 56 条直接前置边。导入前会检查前置编号存在、无自依赖、无重复边，
并通过深度优先遍历拒绝环。Chapter 顺序只负责展示，不能替代 DAG。

## 6. Lesson 骨架

每个知识点包含 3 个有语义的 Lesson，分别承担概念理解、形式练习和情境巩固，
合计 135 节，均带 Lesson 类型、XP、排序和 5～10 分钟学习目标。标题不得使用
`Lesson 1` 一类占位名称。

## 7. 首批完整题目内容

A1-001 至 A1-008 是第一条可真实学习链，共 48 道启用题目。六种现有题型
`SINGLE_CHOICE`、`MULTIPLE_CHOICE`、`FILL_BLANK`、`SENTENCE_ORDER`、
`TRUE_FALSE`、`CORRECTION` 各 8 道。判题继续完全使用现有确定性 evaluator，
正确答案只在提交后返回。

## 8. 导入与幂等规则

local Profile 默认在 Flyway 后运行 `EnglishA1ContentImportRunner`。导入器按语言代码、
等级代码、Chapter 排序位、Grammar Point 稳定编号、Lesson 排序位和 Question 排序位
执行更新或插入。重复导入不会增加启用内容数量；不再属于当前版本的旧 Question 只会
停用，历史 `user_answers` 不删除。

可用 `CONTENT_IMPORT_ENABLED=false` 临时关闭本地内容导入，但常规开发应保持开启。

## 9. 旧数据兼容与版本化债务

旧 `EN_A1_BE_001` 会原位改名为 `A1-003`，不会删除或重建该 Grammar Point，因而其
Lesson、用户进度、答题和错题关系仍指向原 id。Question 目前尚无独立稳定内容编号与
版本列；修改已被用户作答的题目可能改变历史题义。商业化内容迭代前需要增加
`question_code`、`content_version` 和退役策略，而不是覆盖已发布题义。

## 10. 验证清单

- 课程源必须恰好包含 45 个连续 A1 编号、7 个 Chapter、135 个 Lesson。
- 前置图必须包含 56 条无环、无重复、无悬空的边。
- 首批启用题目必须为 48 道且覆盖六种题型。
- 连续执行两次导入后，启用数量和旧 be Grammar Point id 必须保持不变。
- `/api/v1/learning-path/en` 与 `/api/v1/learning-path/en/me` 必须返回真实 45 点数据。
- Flutter 主树必须由 API Chapter 构建，分支树必须使用 API 返回的前置编号连线。
