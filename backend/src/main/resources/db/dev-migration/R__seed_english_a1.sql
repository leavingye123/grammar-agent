INSERT INTO languages (code, name, native_name, enabled, sort_order)
VALUES ('en', 'English', 'English', TRUE, 1)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    native_name = EXCLUDED.native_name,
    enabled = EXCLUDED.enabled,
    sort_order = EXCLUDED.sort_order,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO language_levels (language_id, code, name, description, sort_order)
SELECT id, 'A1', 'A1', '英语入门级：能够理解并使用基础日常表达。', 1
FROM languages
WHERE code = 'en'
ON CONFLICT (language_id, code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO chapters (language_level_id, title, description, sort_order, enabled)
SELECT ll.id, '基础句子', '学习英语基础句型和最常用的语法结构。', 1, TRUE
FROM language_levels ll
JOIN languages l ON l.id = ll.language_id
WHERE l.code = 'en' AND ll.code = 'A1'
ON CONFLICT (language_level_id, sort_order) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    enabled = EXCLUDED.enabled,
    updated_at = CURRENT_TIMESTAMP;

-- Stage 8A compatibility: rename the original be point in place so every
-- foreign key held by user progress, answers and review records remains valid.
UPDATE grammar_points legacy
SET code = 'A1-003', updated_at = CURRENT_TIMESTAMP
FROM chapters c
JOIN language_levels ll ON ll.id = c.language_level_id
JOIN languages l ON l.id = ll.language_id
WHERE legacy.chapter_id = c.id
  AND l.code = 'en'
  AND ll.code = 'A1'
  AND legacy.code = 'EN_A1_BE_001'
  AND NOT EXISTS (
      SELECT 1
      FROM grammar_points stable
      JOIN chapters stable_chapter ON stable_chapter.id = stable.chapter_id
      WHERE stable_chapter.language_level_id = ll.id
        AND stable.code = 'A1-003'
  );

INSERT INTO grammar_points (
    chapter_id, code, title, description, grammar_rule, examples,
    common_errors, difficulty, sort_order, enabled
)
SELECT
    c.id,
    'A1-003',
    'be 动词基础',
    '掌握 am、is、are 在一般现在时中的基本用法。',
    'I 搭配 am；第三人称单数搭配 is；you、we、they 和复数主语搭配 are。',
    '[
      {"sentence":"I am a student.","translation":"我是一名学生。"},
      {"sentence":"She is happy.","translation":"她很开心。"},
      {"sentence":"They are friends.","translation":"他们是朋友。"}
    ]'::JSONB,
    '[
      {"incorrect":"I is a student.","correct":"I am a student."},
      {"incorrect":"They is friends.","correct":"They are friends."}
    ]'::JSONB,
    1,
    1,
    TRUE
FROM chapters c
JOIN language_levels ll ON ll.id = c.language_level_id
JOIN languages l ON l.id = ll.language_id
WHERE l.code = 'en' AND ll.code = 'A1' AND c.sort_order = 1
ON CONFLICT (chapter_id, code) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    grammar_rule = EXCLUDED.grammar_rule,
    examples = EXCLUDED.examples,
    common_errors = EXCLUDED.common_errors,
    difficulty = EXCLUDED.difficulty,
    sort_order = EXCLUDED.sort_order,
    enabled = EXCLUDED.enabled,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO lessons (
    grammar_point_id, title, description, lesson_type,
    xp_reward, sort_order, enabled
)
SELECT
    gp.id,
    'be 动词 Lesson 1',
    '通过基础题练习 am、is、are。',
    'LEARNING',
    10,
    1,
    TRUE
FROM grammar_points gp
JOIN chapters c ON c.id = gp.chapter_id
JOIN language_levels ll ON ll.id = c.language_level_id
JOIN languages l ON l.id = ll.language_id
WHERE l.code = 'en'
  AND ll.code = 'A1'
  AND c.sort_order = 1
  AND gp.code = 'A1-003'
ON CONFLICT (grammar_point_id, sort_order) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    lesson_type = EXCLUDED.lesson_type,
    xp_reward = EXCLUDED.xp_reward,
    enabled = EXCLUDED.enabled,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO questions (
    lesson_id, grammar_point_id, question_type, question_content,
    options, correct_answer, explanation, difficulty, sort_order, enabled
)
SELECT
    lesson.id,
    gp.id,
    seed.question_type,
    seed.question_content,
    seed.options,
    seed.correct_answer,
    seed.explanation,
    seed.difficulty,
    seed.sort_order,
    TRUE
FROM lessons lesson
JOIN grammar_points gp ON gp.id = lesson.grammar_point_id
JOIN chapters c ON c.id = gp.chapter_id
JOIN language_levels ll ON ll.id = c.language_level_id
JOIN languages l ON l.id = ll.language_id
CROSS JOIN (
    VALUES
        (
            'SINGLE_CHOICE',
            'Choose the correct word: I ___ a student.',
            '[{"id":"A","text":"am"},{"id":"B","text":"is"},{"id":"C","text":"are"}]'::JSONB,
            '{"optionId":"A"}'::JSONB,
            '主语 I 必须搭配 be 动词 am。',
            1::SMALLINT,
            1
        ),
        (
            'FILL_BLANK',
            'Fill in the blank: She ___ happy.',
            NULL::JSONB,
            '{"answers":["is"]}'::JSONB,
            'She 是第三人称单数，因此使用 is。',
            1::SMALLINT,
            2
        ),
        (
            'TRUE_FALSE',
            'True or false: “They are friends.” is grammatically correct.',
            '[{"value":true,"text":"True"},{"value":false,"text":"False"}]'::JSONB,
            '{"value":true}'::JSONB,
            'They 是复数主语，需要搭配 are。',
            1::SMALLINT,
            3
        ),
        (
            'CORRECTION',
            'Correct the sentence: She are my teacher.',
            NULL::JSONB,
            '{"acceptedAnswers":["She is my teacher."]}'::JSONB,
            'She 是第三人称单数，应将 are 改为 is。',
            2::SMALLINT,
            4
        ),
        (
            'SENTENCE_ORDER',
            'Put the words in the correct order.',
            '["friends","They","are","."]'::JSONB,
            '{"tokens":["They","are","friends","."]}'::JSONB,
            '英语陈述句的基本顺序是主语 + be 动词 + 表语。',
            2::SMALLINT,
            5
        )
) AS seed(
    question_type, question_content, options, correct_answer,
    explanation, difficulty, sort_order
)
WHERE l.code = 'en'
  AND ll.code = 'A1'
  AND c.sort_order = 1
  AND gp.code = 'A1-003'
  AND lesson.sort_order = 1
ON CONFLICT (lesson_id, sort_order) DO UPDATE SET
    grammar_point_id = EXCLUDED.grammar_point_id,
    question_type = EXCLUDED.question_type,
    question_content = EXCLUDED.question_content,
    options = EXCLUDED.options,
    correct_answer = EXCLUDED.correct_answer,
    explanation = EXCLUDED.explanation,
    difficulty = EXCLUDED.difficulty,
    enabled = EXCLUDED.enabled,
    updated_at = CURRENT_TIMESTAMP;
