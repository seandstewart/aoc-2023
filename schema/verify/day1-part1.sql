-- Verify aoc-2023:day1-part1 on pg

BEGIN;

DO $$
    DECLARE given_calibration_text TEXT;
    DECLARE expected_calibration_values BIGINT[];
    DECLARE expected_calibration_total BIGINT;
    DECLARE test_calibration_attempt_id BIGINT;
    DECLARE calibration_values BIGINT[];
    DECLARE calibration_total BIGINT;
    BEGIN
        -- Given
        given_calibration_text := '1abc2
        pqr3stu8vwx
        a1b2c3d4e5f
        treb7uchet
        ';
        expected_calibration_values := ARRAY [12, 38, 15, 77];
        expected_calibration_total := 142;
        -- When
        test_calibration_attempt_id := (
            SELECT trebuchet.save_calibration_values(given_calibration_text)
        );
        calibration_values := array(
            SELECT value
            FROM trebuchet.calibration_value cv
            WHERE cv.calibration_attempt_id = test_calibration_attempt_id
        );
        calibration_total := (
            SELECT sum(value)
            FROM trebuchet.calibration_value cv
            WHERE cv.calibration_attempt_id = test_calibration_attempt_id
        );
        -- Then
        ASSERT calibration_values = expected_calibration_values,
            'Unexpected values: '
            || calibration_values::text
            || ' != '
            || expected_calibration_values::text
        ;
        ASSERT calibration_total = expected_calibration_total,
            'Unexpected total: '
            || calibration_total::text
            || ' != '
            || expected_calibration_total::text;
    END
$$;

ROLLBACK;
