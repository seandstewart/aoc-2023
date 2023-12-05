-- Verify aoc-2023:day4-part1 on pg

BEGIN;

DO $$
    DECLARE given_scratch_off_text TEXT;
    DECLARE expected_scratch_off_points BIGINT[];
    DECLARE expected_scratch_off_total BIGINT;
    DECLARE test_scratch_off_series_id BIGINT;
    DECLARE scratch_off_points BIGINT[];
    DECLARE scratch_off_total BIGINT;

    BEGIN
        -- Given
        given_scratch_off_text := '
        Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        ';
        expected_scratch_off_points := ARRAY [8, 2, 2, 1, 0, 0];
        expected_scratch_off_total := 13;
        -- When
        test_scratch_off_series_id := (
            SELECT trebuchet.save_scratch_off_series(given_scratch_off_text)
        );
        scratch_off_points := array(
            SELECT points
            FROM trebuchet.scratch_off
            WHERE series_id = test_scratch_off_series_id
            ORDER BY number
        );
        scratch_off_total := (
            SELECT sum(points)
            FROM trebuchet.scratch_off
            WHERE series_id = test_scratch_off_series_id
        );
        RAISE NOTICE 'Scratch off points: %', scratch_off_points::text;
        RAISE NOTICE 'Scratch off total: %', scratch_off_total::text;
        -- Then
        ASSERT scratch_off_points = expected_scratch_off_points,
            'Unexpected values: '
            || scratch_off_points::text
            || ' != '
            || expected_scratch_off_points::text
        ;
        ASSERT scratch_off_total = expected_scratch_off_total,
            'Unexpected total: '
            || scratch_off_total::text
            || ' != '
            || expected_scratch_off_total::text;

    END;
$$;

COMMIT ;
