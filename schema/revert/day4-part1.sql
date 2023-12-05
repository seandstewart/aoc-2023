-- Revert aoc-2023:day4-part1 from pg

BEGIN;

DROP FUNCTION IF EXISTS trebuchet.save_scratch_off_series;
DROP INDEX IF EXISTS trebuchet.uidx_scratch_off_series_name;
DROP TABLE IF EXISTS trebuchet.scratch_off;
DROP TABLE IF EXISTS trebuchet.scratch_off_series;
DROP FUNCTION IF EXISTS array_intersect;
DROP FUNCTION IF EXISTS array_power;

COMMIT;
