-- Deploy aoc-2023:day3-part2 to pg
-- requires: day3-part1

BEGIN;

DROP TYPE IF EXISTS trebuchet.engine_gear CASCADE;
CREATE TYPE trebuchet.engine_gear AS (
    gear_id BIGINT,
    part_numbers BIGINT[]
);
CREATE OR REPLACE FUNCTION trebuchet.locate_gear_part_numbers("engine_matrix_id" bigint)
RETURNS SETOF trebuchet.engine_gear AS $$
    WITH gears AS (
        SELECT *
        FROM trebuchet.engine_matrix_entries
        WHERE matrix_id = engine_matrix_id
        AND value = '*'
    ), adjacent_numbers AS (
        SELECT
            g.id,
            trebuchet.build_number_for_entry(eme.id) AS part_number
        FROM trebuchet.engine_matrix_entries eme
            INNER JOIN gears g
                ON g.matrix_id = eme.matrix_id
                AND g.boundary @> eme.location
                AND eme.is_numeric
        ORDER BY g.id, eme.location[2], eme.location[1]
    ), distinct_numbers AS (
        SELECT DISTINCT ON (an.part_number)
            an.id,
            an.part_number
        FROM adjacent_numbers an
    ), agged_numbers AS (
        SELECT
            distinct_numbers.id,
            array_agg((distinct_numbers.part_number).number) as part_numbers
        FROM distinct_numbers
        GROUP BY distinct_numbers.id
    )
    SELECT * FROM agged_numbers WHERE array_length(part_numbers, 1) > 1
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION trebuchet.calculate_gear_ratios("engine_matrix_id" bigint)
RETURNS SETOF BIGINT AS $$
    DECLARE gear trebuchet.engine_gear;
    DECLARE ratio BIGINT;
    DECLARE number BIGINT;
    DECLARE ratios BIGINT[] := ARRAY[]::bigint[];
    BEGIN
        FOR gear IN (
            SELECT *
            FROM trebuchet.locate_gear_part_numbers(engine_matrix_id)
        )
        LOOP
            ratio := 1;
            FOREACH number IN ARRAY gear.part_numbers
            LOOP
                ratio := ratio * number;
            END LOOP;
            ratios := array_append(ratios, ratio);
        END LOOP;
    RETURN QUERY (SELECT unnest(ratios) AS ratio);
    END;
$$ LANGUAGE plpgsql;
COMMIT;
