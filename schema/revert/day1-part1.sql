-- Revert aoc-2023:day1-part1 from pg

BEGIN;

DROP TABLE IF EXISTS trebuchet.calibration_attempt;
DROP TABLE IF EXISTS trebuchet.calibration_value;
DROP FUNCTION IF EXISTS trebuchet.save_calibration_values;

COMMIT;
