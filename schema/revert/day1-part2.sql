-- Revert aoc-2023:day1-part2 from pg

BEGIN;

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
            SELECT
                regexp_replace(tb, E'[a-zA-Z]', '', 'g') as nums
            FROM regexp_split_to_table("values", E'\\s+') as tb
            WHERE length(tb) > 0
        ) as parsed, lateral ( SELECT id FROM new_attempt LIMIT 1) na
    )
    SELECT id FROM new_attempt LIMIT 1
$$ LANGUAGE sql;

DROP FUNCTION IF EXISTS transliterate_numbers;
DROP TABLE IF EXISTS number_dictionary;

COMMIT;
