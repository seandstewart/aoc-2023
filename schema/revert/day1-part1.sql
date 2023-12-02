-- Revert aoc-2023:day1-part1 from pg

BEGIN;

DROP FUNCTION IF EXISTS trebuchet.save_calibration_values;
DROP TABLE IF EXISTS trebuchet.calibration_value;
DROP TABLE IF EXISTS trebuchet.calibration_attempt;

COMMIT;
