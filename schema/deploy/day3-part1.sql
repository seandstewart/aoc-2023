-- Deploy aoc-2023:day3-part1 to pg
-- requires: init

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist CASCADE;

CREATE TABLE IF NOT EXISTS trebuchet.engine_matrix (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS trebuchet.engine_matrix_entries (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    matrix_id BIGINT NOT NULL REFERENCES trebuchet.engine_matrix (id) ON DELETE CASCADE,
    location point,
    boundary box,
    value TEXT DEFAULT NULL,
    is_numeric BOOLEAN DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS idx_engine_matrix_entries_location
    ON trebuchet.engine_matrix_entries USING gist(matrix_id, location);

CREATE OR REPLACE FUNCTION trebuchet.save_engine_matrix("input" text)
RETURNS BIGINT AS $$
    WITH new_matrix AS (INSERT INTO trebuchet.engine_matrix DEFAULT VALUES RETURNING *),
    entries AS (
        SELECT
            row_number() over (partition by yindex) AS xindex,
            xy.yindex,
            CASE WHEN xy.value = '.' THEN null ELSE xy.value END AS value,
            xy.value SIMILAR TO '[[:digit:]]+' AS is_numeric
        FROM (
            SELECT
                row_number() over (partition by null) as yindex,
                regexp_split_to_table(y.rows, '') as value
            FROM (
                SELECT regexp_split_to_table(
                    input,
                    '[[:space:]]+'
                ) rows
            ) y
            WHERE y.rows != ''
        ) xy
    ),
    new_entries AS (
        INSERT INTO trebuchet.engine_matrix_entries (
            matrix_id, location, boundary, value, is_numeric
        )
        SELECT
            nm.id,
            point(e.xindex, e.yindex),
            box(
                point(e.xindex, e.yindex) - point(1,1),
                point(e.xindex, e.yindex) + point(1,1)
            ),
            e.value,
            e.is_numeric
        FROM entries e, LATERAL ( SELECT id FROM new_matrix LIMIT 1 ) nm
    )
    SELECT id FROM new_matrix LIMIT 1
$$ LANGUAGE sql;

DROP TYPE IF EXISTS part_number CASCADE;
DROP TYPE IF EXISTS trebuchet.part_number CASCADE;
CREATE TYPE trebuchet.part_number AS (number bigint, locales text);
DROP FUNCTION IF EXISTS trebuchet.build_number_for_entry;
CREATE OR REPLACE FUNCTION trebuchet.build_number_for_entry("entry_id" bigint)
RETURNS trebuchet.part_number AS $$
    DECLARE builder TEXT := '';
    DECLARE right_entry trebuchet.engine_matrix_entries := null;
    DECLARE left_entry trebuchet.engine_matrix_entries := null;
    DECLARE entry trebuchet.engine_matrix_entries;
    DECLARE engine_matrix_id BIGINT;
    DECLARE rpos point;
    DECLARE lpos point;
    DECLARE seen_locales point[];

    BEGIN
        entry := (
            SELECT eme
            FROM trebuchet.engine_matrix_entries eme
            WHERE id = entry_id AND is_numeric
            LIMIT 1
        );
        RAISE NOTICE 'Initial value, location: %, %', entry.value, entry.location;
        IF entry IS NULL THEN
            RETURN null;
        END IF;
        engine_matrix_id := entry.matrix_id;
        rpos := entry.location + point(1, 0);
        lpos := entry.location - point(1, 0);
        builder := entry.value;
        seen_locales := ARRAY [entry.location];
        -- Search to the left
        left_entry := entry;
        RAISE INFO 'Seeking left. Start value, location: %, %', left_entry.value, left_entry.location;
        WHILE left_entry IS NOT NULL LOOP
            RAISE INFO 'Locale: %', lpos;
            seen_locales := ARRAY [lpos] || seen_locales;
            left_entry := (
                SELECT eme
                FROM trebuchet.engine_matrix_entries eme
                WHERE location ~= lpos
                AND matrix_id = engine_matrix_id
                AND is_numeric
            );
            RAISE INFO 'Left value, location: %, %', left_entry.value, left_entry.location;
            IF left_entry IS NOT NULL THEN
                builder := left_entry.value || builder;
                RAISE INFO 'Concatenated value: %', builder;
                lpos := left_entry.location - point(1, 0);
            END IF;
        END LOOP;
        -- Search to the right
        right_entry := entry;
        RAISE INFO 'Seeking right. Start value, location: %, %', right_entry.value, right_entry.location;
        WHILE right_entry IS NOT NULL LOOP
            RAISE INFO 'Locale: %', rpos;
            seen_locales := array_append(seen_locales, rpos);
            right_entry := (
                SELECT eme
                FROM trebuchet.engine_matrix_entries eme
                WHERE location ~= rpos
                AND matrix_id = engine_matrix_id
                AND is_numeric
            );
            RAISE INFO 'Right value, location: %, %', right_entry.value, right_entry.location;
            IF right_entry IS NOT NULL THEN
                builder := builder || right_entry.value;
                RAISE INFO 'Concatenated value: %', builder;
                rpos := right_entry.location + point(1, 0);
            END IF;
        END LOOP;
        RAISE NOTICE 'Built number: %', builder;
        RAISE NOTICE 'Locales: %', seen_locales;
        RETURN (builder::bigint, seen_locales::text)::trebuchet.part_number;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trebuchet.matrix_entry_has_adjacent_symbol("entry_id" bigint)
RETURNS BOOLEAN AS $$
    SELECT sum(symbols.found) > 0
    FROM (
        SELECT 1 AS found
        FROM trebuchet.engine_matrix_entries eme
            INNER JOIN trebuchet.engine_matrix_entries eme_root
                ON eme_root.id = entry_id
                AND eme.matrix_id = eme_root.matrix_id
                AND eme.id != eme_root.id
                AND eme.location <@ eme_root.boundary
                AND eme.value IS NOT NULL
                AND eme_root.value IS NOT NULL
                AND eme.is_numeric IS FALSE
    ) symbols
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION trebuchet.locate_engine_parts("engine_matrix_id" bigint)
RETURNS SETOF bigint AS $$
    SELECT number FROM (
        SELECT DISTINCT
            ((trebuchet.build_number_for_entry(eme.id))::trebuchet.part_number).*
        FROM trebuchet.engine_matrix_entries eme
        WHERE
            eme.matrix_id = engine_matrix_id
            AND eme.is_numeric
            AND trebuchet.matrix_entry_has_adjacent_symbol(eme.id)
    ) numbers

$$ LANGUAGE sql;

COMMIT;
