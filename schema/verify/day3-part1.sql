-- Verify aoc-2023:day2-part1 on pg

BEGIN;

DO $$
    DECLARE given_matrix_text TEXT;
    DECLARE expected_engine_parts BIGINT[];
    DECLARE expected_engine_parts_total BIGINT;
    DECLARE test_engine_matrix_id BIGINT;
    DECLARE engine_parts BIGINT[];
    DECLARE engine_parts_total BIGINT;

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
        expected_engine_parts := ARRAY [35, 467, 592, 598, 617, 633, 664, 755];
        expected_engine_parts_total := 4361;
        -- When
        test_engine_matrix_id := (
            SELECT trebuchet.save_engine_matrix(given_matrix_text)
        );
        engine_parts := array(
            SELECT trebuchet.locate_engine_parts(test_engine_matrix_id)
        );

        engine_parts_total := (
            SELECT sum(part::bigint) FROM (
                SELECT * FROM
                trebuchet.locate_engine_parts(test_engine_matrix_id)
                AS parts(part)
            ) p
        );

        RAISE NOTICE 'Engine parts: %', engine_parts::text;
        RAISE NOTICE 'Parts total: %', engine_parts_total::text;
        -- Then
        ASSERT engine_parts = expected_engine_parts,
            'Unexpected values: '
            || engine_parts::text
            || ' != '
            || expected_engine_parts::text
        ;
        ASSERT engine_parts_total = expected_engine_parts_total,
            'Unexpected total: '
            || engine_parts_total::text
            || ' != '
            || expected_engine_parts_total::text;
    END;
$$;

ROLLBACK;
