-- Verify aoc-2023:day2-part1 on pg

BEGIN;

DO $$
    DECLARE given_games_text TEXT;
    DECLARE expected_game_numbers BIGINT[];
    DECLARE expected_game_powers BIGINT[];
    DECLARE expected_game_total BIGINT;
    DECLARE expected_power_total BIGINT;
    DECLARE test_game_series_id BIGINT;
    DECLARE game_numbers BIGINT[];
    DECLARE game_powers BIGINT[];
    DECLARE game_total BIGINT;
    DECLARE power_total BIGINT;

    BEGIN
        -- Given
        given_games_text := '
        Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        ';
        expected_game_numbers := ARRAY [1, 2, 5];
        expected_game_powers := ARRAY [48, 12, 1560, 630, 36];
        expected_game_total := 8;
        expected_power_total := 2286;
        -- When
        test_game_series_id := (
            SELECT trebuchet.save_cube_game_series(given_games_text)
        );
        game_numbers := array(
            SELECT cg.number
            FROM trebuchet.cube_game cg
            INNER JOIN trebuchet.cube_game_round c on cg.id = c.game_id
            WHERE cg.series_id = test_game_series_id
            GROUP BY cg.number
            HAVING
                max(c.blue) <= 14
                AND max(c.green) <= 13
                AND max(c.red) <= 12
            ORDER BY cg.number

        );

        game_total := (
            SELECT sum(number) FROM (
                SELECT cg.number
                FROM trebuchet.cube_game cg
                INNER JOIN trebuchet.cube_game_round c on cg.id = c.game_id
                WHERE cg.series_id = test_game_series_id
                GROUP BY cg.number
                HAVING
                    max(c.blue) <= 14
                    AND max(c.green) <= 13
                    AND max(c.red) <= 12
            ) numbers);

        game_powers := array(
            SELECT max(c.blue) * max(c.green) * max(c.red) as power
            FROM trebuchet.cube_game cg
            INNER JOIN trebuchet.cube_game_round c on cg.id = c.game_id
            WHERE cg.series_id = test_game_series_id
            GROUP BY cg.number
            ORDER BY cg.number
        );
        power_total := (
            SELECT sum(power) FROM (
                SELECT
                    cg.number,
                    max(c.blue) * max(c.green) * max(c.red) as power
                FROM trebuchet.cube_game cg
                INNER JOIN trebuchet.cube_game_round c on cg.id = c.game_id
                WHERE cg.series_id = test_game_series_id
                GROUP BY cg.number
            ) powers
        );
        RAISE NOTICE 'Game numbers: %', game_numbers::text;
        RAISE NOTICE 'Game total: %', game_total::text;
        -- Then
        ASSERT game_numbers = expected_game_numbers,
            'Unexpected values: '
            || game_numbers::text
            || ' != '
            || expected_game_numbers::text
        ;
        ASSERT game_total = expected_game_total,
            'Unexpected total: '
            || game_total::text
            || ' != '
            || expected_game_total::text;

         ASSERT game_powers = expected_game_powers,
            'Unexpected powers: '
            || game_numbers::text
            || ' != '
            || expected_game_numbers::text
        ;
        ASSERT power_total = expected_power_total,
            'Unexpected power total: '
            || game_total::text
            || ' != '
            || expected_game_total::text;

    END;

$$;

ROLLBACK ;
