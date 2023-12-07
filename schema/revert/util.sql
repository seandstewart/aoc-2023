-- Revert aoc-2023:util from pg

BEGIN;

DROP FUNCTION IF EXISTS lsv_to_table(text);
DROP FUNCTION IF EXISTS labeled(text);
DROP FUNCTION IF EXISTS int_table(text);
DROP FUNCTION IF EXISTS int_array(text);
DROP FUNCTION IF EXISTS counter(text);

COMMIT;
