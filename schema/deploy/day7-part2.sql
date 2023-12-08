-- Deploy aoc-2023:day7-part2 to pg
-- requires: day7-part1

BEGIN;

CREATE OR REPLACE FUNCTION trebuchet.card_hand_to_ranking(bigint)
RETURNS TABLE (
    id bigint,
    hand text,
    bet bigint,
    combo_rank bigint,
    card_combo bigint[],
    joker_combo bigint[],
    card_ranks bigint[],
    overall_rank bigint
) AS $$
    WITH rounds AS (
        SELECT * FROM trebuchet.camel_card_round WHERE game_id = $1
    ),
    cards AS (
        SELECT DISTINCT rounds.id, rounds.hand, rounds.bet, cc.label, cc.rank, chars.index
        FROM rounds, LATERAL ( SELECT * FROM char_table(rounds.hand) ) chars
            INNER JOIN trebuchet.camel_card cc
                ON chars.value = cc.label
        ORDER BY chars.index
    ),
    counts AS (
        SELECT DISTINCT rounds.id, rounds.hand, rounds.bet, cc.label, cc.rank, count.occurrences
        FROM rounds, LATERAL ( SELECT * FROM counter(rounds.hand) ) count
            INNER JOIN trebuchet.camel_card cc
                ON count.value = cc.label
        ORDER BY rounds.hand, count.occurrences DESC, cc.rank DESC
    ),
    jokered AS (
        SELECT high.id, high.hand, joker.value AS label, joker.occurrences
        FROM (SELECT DISTINCT ON (hand) * FROM counts WHERE label != 'J') high, LATERAL (
            SELECT * FROM counter(replace(hand, 'J', high.label))
        ) joker
    ), merged AS (
        SELECT
            cards_agg.hand,
            cards_agg.card_ranks,
            counts_agg.real_combo,
            coalesce(jokered_agg.jokered_combo, counts_agg.real_combo) AS jokered_combo
        FROM (
            SELECT cards.id, cards.hand, array_agg(cards.rank ORDER BY cards.index) AS card_ranks
            FROM cards GROUP BY cards.id, cards.hand
        ) cards_agg
        INNER JOIN (
            SELECT id, hand, array_agg(occurrences) as real_combo
            FROM counts GROUP BY counts.id, counts.hand
        ) counts_agg ON counts_agg.id = cards_agg.id
        LEFT JOIN (
            SELECT id, hand, array_agg(occurrences) as jokered_combo
            FROM jokered GROUP BY jokered.id, jokered.hand
        ) jokered_agg ON jokered_agg.id = cards_agg.id
    )
    SELECT
        rounds.id,
        merged.hand,
        rounds.bet,
        cch.rank AS combo_rank,
        merged.real_combo AS card_combo,
        merged.jokered_combo,
        merged.card_ranks,
        rank() OVER (ORDER BY cch.rank, merged.card_ranks) as overall_rank
    FROM merged
        INNER JOIN rounds ON merged.hand = rounds.hand
        INNER JOIN trebuchet.camel_card_hand cch
            ON cch.combination = merged.jokered_combo
    ORDER BY combo_rank, card_ranks


$$ LANGUAGE sql IMMUTABLE;

INSERT INTO trebuchet.camel_card(label, rank) VALUES
    ('A', 13),
    ('K', 12),
    ('Q', 11),
    ('T', 10),
    ('9', 9),
    ('8', 8),
    ('7', 7),
    ('6', 6),
    ('5', 5),
    ('4', 4),
    ('3', 3),
    ('2', 2),
    ('J', 1)
ON CONFLICT (label) DO UPDATE SET rank = excluded.rank;


COMMIT;
