-- Deploy aoc-2023:day1-part2 to pg
-- requires: init

BEGIN;

CREATE TABLE IF NOT EXISTS number_dictionary (
    number BIGINT NOT NULL PRIMARY KEY,
    word TEXT NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);
CREATE UNIQUE INDEX IF NOT EXISTS uidx_number_dictionary_word
    ON number_dictionary (word);

INSERT INTO number_dictionary (number, word)
VALUES
    (0, 'zero'),
    (1, 'one'),
    (2, 'two'),
    (3, 'three'),
    (4, 'four'),
    (5, 'five'),
    (6, 'six'),
    (7, 'seven'),
    (8, 'eight'),
    (9, 'nine')
ON CONFLICT DO NOTHING
;

CREATE OR REPLACE FUNCTION transliterate_numbers("value" text) RETURNS text AS $$
    <<replace_words>>
    DECLARE
        out text;
        num bigint;
        wrd text;
        chr text;
    BEGIN
        RAISE NOTICE 'Value: %', value;
        FOREACH chr IN ARRAY regexp_split_to_array("value", '')
        LOOP
            wrd := concat(wrd, chr);
            RAISE DEBUG 'Word: %', wrd;
            num := (regexp_match(wrd, '[[:digit:]]'))[1]::bigint;
            IF num IS NULL THEN
                num := (
                    SELECT number
                    FROM number_dictionary
                    WHERE regexp_like(wrd, word)
                    LIMIT 1
                );

            END IF;
            RAISE DEBUG 'Num: %', num;
            IF num IS NOT NULL THEN
                out := concat(out, num::text);
                num := null;
                wrd := chr;
                IF regexp_like(chr, '[[:digit:]]') THEN
                    wrd := null;
                END IF;
            END IF;
        END LOOP;
    RAISE NOTICE 'Out: %', out;
    RETURN out;
    END replace_words
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION trebuchet.save_calibration_values("values" text)
RETURNS BIGINT AS $$
    WITH new_attempt AS (
        INSERT INTO trebuchet.calibration_attempt DEFAULT VALUES RETURNING *
    ), values_list AS (
        INSERT INTO trebuchet.calibration_value (calibration_attempt_id, value)
        SELECT
            na.id AS calibration_attempt_id,
            cast("left"(nums, 1) || "right"(nums, 1) AS bigint) as value
        FROM (
            SELECT transliterate_numbers(tb) as nums
            FROM regexp_split_to_table("values", E'[[:space:]]+') as tb
            WHERE length(tb) > 0
        ) as parsed, lateral ( SELECT id FROM new_attempt LIMIT 1) na
    )
    SELECT id FROM new_attempt LIMIT 1
$$ LANGUAGE sql;

COMMIT;
