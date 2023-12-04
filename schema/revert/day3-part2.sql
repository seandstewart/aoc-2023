-- Revert aoc-2023:day3-part2 from pg

BEGIN;

DROP FUNCTION IF EXISTS trebuchet.calculate_gear_ratios;
DROP FUNCTION IF EXISTS trebuchet.locate_gear_part_numbers;
DROP TYPE IF EXISTS trebuchet.engine_gear;

COMMIT;
