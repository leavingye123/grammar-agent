ALTER TABLE questions
    ADD COLUMN question_code VARCHAR(32);

WITH ranked_questions AS (
    SELECT
        q.id,
        gp.code || '-Q' || LPAD(
            (
                CASE
                    WHEN q.enabled THEN ROW_NUMBER() OVER (
                        PARTITION BY q.grammar_point_id, q.enabled
                        ORDER BY l.sort_order, q.sort_order, q.id
                    )
                    ELSE 900 + ROW_NUMBER() OVER (
                        PARTITION BY q.grammar_point_id, q.enabled
                        ORDER BY l.sort_order, q.sort_order, q.id
                    )
                END
            )::TEXT,
            3,
            '0'
        ) AS generated_code
    FROM questions q
    JOIN lessons l ON l.id = q.lesson_id
    JOIN grammar_points gp ON gp.id = q.grammar_point_id
)
UPDATE questions q
SET question_code = ranked.generated_code
FROM ranked_questions ranked
WHERE ranked.id = q.id;

ALTER TABLE questions
    ALTER COLUMN question_code SET NOT NULL;

ALTER TABLE questions
    ADD CONSTRAINT uk_questions_question_code UNIQUE (question_code),
    ADD CONSTRAINT ck_questions_question_code CHECK (
        question_code ~ '^[A-Z][0-9]-[0-9]{3}-Q[0-9]{3}$'
    );
