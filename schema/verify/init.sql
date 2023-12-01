-- Verify aoc-2023:init on pg

BEGIN;

SELECT has_schema_privilege('trebuchet', 'usage');

ROLLBACK;
