-- Verify aoc-2023:day7-part1 on pg

BEGIN;

DO $$
    DECLARE given_card_game_text TEXT;
    DECLARE expected_rankings jsonb;
    DECLARE expected_score BIGINT;
    DECLARE test_card_game_id BIGINT;
    DECLARE rankings jsonb;
    DECLARE score BIGINT;
    BEGIN
        -- Given
        given_card_game_text := '32T3K 765
        T55J5 684
        KK677 28
        KTJJT 220
        QQQJA 483
        ';
        expected_rankings := '[{"bet": 765, "hand": "32T3K", "rank": 1}, {"bet": 220, "hand": "KTJJT", "rank": 2}, {"bet": 28, "hand": "KK677", "rank": 3}, {"bet": 684, "hand": "T55J5", "rank": 4}, {"bet": 483, "hand": "QQQJA", "rank": 5}]';
        expected_score := 6440;
        -- When
        test_card_game_id := (
            SELECT trebuchet.save_camel_card_game(given_card_game_text)
        );
        rankings := (
            SELECT to_jsonb(array (SELECT trebuchet.rank_camel_card_rounds(test_card_game_id)))
        );
        score := (
            SELECT sum(bet * rank)
            FROM trebuchet.rank_camel_card_rounds(test_card_game_id)
        );
        -- Then
        ASSERT rankings @> expected_rankings AND rankings <@ expected_rankings,
            'Unexpected values: '
            || rankings::text
            || ' != '
            || expected_rankings::text
        ;
        ASSERT score = expected_score,
            'Unexpected total: '
            || score::text
            || ' != '
            || expected_score::text;
    END
$$;

ROLLBACK;
