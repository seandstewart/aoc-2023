-- Deploy aoc-2023:day4-part1 to pg
-- requires: init

BEGIN;

-- region: schema

CREATE OR REPLACE FUNCTION array_intersect(arr1 anyarray, arr2 anyarray)
RETURNS anyarray AS $$
    SELECT array (SELECT unnest(arr1) INTERSECT SELECT unnest(arr2))
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION array_power(arr bigint[], power bigint) RETURNS BIGINT AS $$
    DECLARE length BIGINT;
    DECLARE number BIGINT;
    DECLARE power BIGINT;
    BEGIN
        length := coalesce(array_length(arr, 1), 0);
        IF length < 2 THEN
            RETURN length;
        END IF;
        power := 1;
        FOREACH number IN ARRAY arr[2:length]
        LOOP
            power := power * 2;
        END LOOP;
        RETURN power;
    end;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE TABLE IF NOT EXISTS trebuchet.scratch_off_series (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS trebuchet.scratch_off (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    series_id BIGINT NOT NULL
        REFERENCES trebuchet.scratch_off_series(id) ON DELETE CASCADE,
    number BIGINT NOT NULL,
    player_numbers BIGINT[] NOT NULL,
    house_numbers BIGINT[] NOT NULL,
    intersection BIGINT[] NOT NULL,
    points BIGINT NOT NULL GENERATED ALWAYS AS (
        array_power(intersection, 2)
    ) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX IF NOT EXISTS uidx_scratch_off_series_name
    ON trebuchet.scratch_off(series_id, number);

-- endregion
-- region: logic

CREATE OR REPLACE FUNCTION trebuchet.save_scratch_off_series("value" text)
RETURNS BIGINT AS $$
    WITH new_series AS (
        INSERT INTO trebuchet.scratch_off_series DEFAULT VALUES RETURNING *
    ), _scratch_off_numbers_parsed AS (
        INSERT INTO trebuchet.scratch_off (
            series_id, number, house_numbers, player_numbers, intersection
        )
        SELECT
            parsed.*,
            (
                array_intersect(house_numbers, player_numbers)
            )::bigint[] AS intersection
        FROM (
            SELECT
                ns.id AS series_id,
                gg.game_number AS number,
                (regexp_split_to_array(gg.number_sets[1], '[[:space:]]+'))::bigint[] AS house_numbers,
                (regexp_split_to_array(gg.number_sets[2], '[[:space:]]+'))::bigint[] AS player_numbers
            FROM (
                SELECT
                    ((regexp_match(g.parts[1], '[[:digit:]]+'))[1])::bigint AS game_number,
                    regexp_split_to_array(g.parts[2], '[[:space:]]+\|[[:space:]]+') AS number_sets
                FROM (
                    SELECT
                        regexp_split_to_array(
                            regexp_split_to_table("value", E'\\n+'),
                            ':[[:space:]]+'
                        ) parts
                    ) g
                    WHERE array_length(g.parts, 1) = 2
            ) gg, lateral (
                SELECT id FROM new_series LIMIT 1
            ) ns
        ) parsed
        ON CONFLICT (series_id, number) DO NOTHING
    )
    SELECT id FROM new_series;
$$ LANGUAGE sql;

COMMIT;
