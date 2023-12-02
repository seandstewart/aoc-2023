-- Verify aoc-2023:day1-part2 on pg

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
        given_calibration_text := 'two1nine
        eightwothree
        abcone2threexyz
        xtwone3four
        4nineeightseven2
        zoneight234
        7pqrstsixteen
        ';
        expected_calibration_values := ARRAY [29, 83, 13, 24, 42, 14, 76];
        expected_calibration_total := 281;
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
