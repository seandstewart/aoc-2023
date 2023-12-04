-- Verify aoc-2023:day2-part1 on pg

BEGIN;

DO $$
    DECLARE given_matrix_text TEXT;
    DECLARE expected_gear_part_numbers BIGINT[][];
    DECLARE expected_gear_ratios_total BIGINT;
    DECLARE test_engine_matrix_id BIGINT;
    DECLARE gear_part_numbers BIGINT[];
    DECLARE gear_ratios_total BIGINT;

    BEGIN
        -- Given
        given_matrix_text := '
        467..114..
        ...*......
        ..35..633.
        ......#...
        617*......
        .....+.58.
        ..592.....
        ......755.
        ...$.*....
        .664.598..
        ';
        expected_gear_part_numbers := ARRAY [[598, 755], [35, 467]];
        expected_gear_ratios_total := 467835;
        -- When
        test_engine_matrix_id := (
            SELECT trebuchet.save_engine_matrix(given_matrix_text)
        );
        gear_part_numbers := array(
            SELECT (trebuchet.locate_gear_part_numbers(test_engine_matrix_id)).part_numbers
        );

        gear_ratios_total := (
            SELECT sum(ratio::bigint) FROM (
                SELECT * FROM
                trebuchet.calculate_gear_ratios(test_engine_matrix_id)
                AS ratios(ratio)
            ) p
        );

        RAISE NOTICE 'Gear parts: %', gear_part_numbers::text;
        RAISE NOTICE 'Gear ratio total: %', gear_ratios_total::text;
        -- Then
        ASSERT gear_part_numbers = expected_gear_part_numbers,
            'Unexpected values: '
            || gear_part_numbers::text
            || ' != '
            || expected_gear_part_numbers::text
        ;
        ASSERT gear_ratios_total = expected_gear_ratios_total,
            'Unexpected total: '
            || gear_ratios_total::text
            || ' != '
            || expected_gear_ratios_total::text;
    END;
$$;

ROLLBACK;
