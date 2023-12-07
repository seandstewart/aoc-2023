-- Deploy aoc-2023:util to pg
-- requires: init

BEGIN;

CREATE OR REPLACE FUNCTION lsv_to_table(text)
RETURNS TABLE (value text, index bigint) AS $$
    SELECT
        unnest(s.split) AS value,
        -- Order-preserving method to enumerate an index value.
        --  row_number() needs a deterministic sort, which we don't have yet.
        generate_series(1, array_length(s.split, 1)) AS index
    FROM (
        SELECT array_agg(t.tsplit) split
        FROM (SELECT trim(regexp_split_to_table($1, E'\\n+')) AS tsplit) t
        WHERE t.tsplit != ''
    ) s
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION lsv_to_table(value text) IS
    'Split a line-separated input into a table. Trims whitespace from edges';

CREATE OR REPLACE FUNCTION labeled(text)
RETURNS TABLE (label text, value text) AS $$
    SELECT
        trim(s.split[1]) AS label,
        trim(s.split[2]) AS value
    FROM (SELECT regexp_split_to_array($1, E':[[:space:]]+') as split) s
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION labeled(text) IS
    'Split a colon (:) separated text value into a labeled table.';

CREATE OR REPLACE FUNCTION int_array(text) RETURNS bigint[] AS $$
    SELECT array (SELECT (regexp_matches($1, '[[:digit:]]+', 'g'))[1])::bigint[]
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION int_array(text) IS
    'Split a text input into an array of integers';


CREATE OR REPLACE FUNCTION int_table(text)
RETURNS TABLE (value bigint, index bigint) AS $$
    SELECT
        unnest(s.split) AS value,
        generate_series(1, array_length(s.split, 1)) AS index
    FROM (SELECT int_array($1) as split) s
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;
COMMENT ON FUNCTION int_array(text) IS
    'Split a text input into an table of integers';


CREATE OR REPLACE FUNCTION counter(text)
RETURNS TABLE (value text, occurrences bigint) AS $$
    SELECT
        trim(unnest(s.split)) AS value,
        count(*) AS occurrence
    FROM (SELECT regexp_split_to_array($1, '') split) s
    GROUP BY 1 ORDER BY 2 DESC
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;

COMMIT;