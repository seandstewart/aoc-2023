-- Deploy aoc-2023:day7-part1 to pg
-- requires: util

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS trebuchet.camel_card (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp,
    label TEXT NOT NULL,
    rank BIGINT NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS uidx_camel_card_label ON trebuchet.camel_card (label);
INSERT INTO trebuchet.camel_card(label, rank) VALUES
    ('A', 13),
    ('K', 12),
    ('Q', 11),
    ('J', 10),
    ('T', 9),
    ('9', 8),
    ('8', 7),
    ('7', 6),
    ('6', 5),
    ('5', 4),
    ('4', 3),
    ('3', 2),
    ('2', 1)
ON CONFLICT (label) DO UPDATE SET rank = excluded.rank;

CREATE TABLE IF NOT EXISTS trebuchet.camel_card_hand (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp,
    combination BIGINT[] NOT NULL CHECK ( array_sum(combination) = 5 ),
    rank BIGINT NOT NULL
);
CREATE UNIQUE INDEX uidx_camel_card_hand_combination
    ON trebuchet.camel_card_hand (combination);
INSERT INTO trebuchet.camel_card_hand(combination, rank) VALUES
    (ARRAY[5]::bigint[], 7),
    (ARRAY[4,1]::bigint[], 6),
    (ARRAY[3,2]::bigint[], 5),
    (ARRAY[3,1,1]::bigint[], 4),
    (ARRAY[2,2,1]::bigint[], 3),
    (ARRAY[2,1,1,1]::bigint[], 2),
    (ARRAY[1,1,1,1,1]::bigint[], 1)
ON CONFLICT (combination) DO UPDATE SET rank = excluded.rank;

CREATE TABLE IF NOT EXISTS trebuchet.camel_card_game (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS trebuchet.camel_card_round (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp,
    game_id BIGINT NOT NULL REFERENCES trebuchet.camel_card_game (id) ON DELETE CASCADE,
    hand TEXT NOT NULL CHECK ( length(hand) = 5 ),
    bet BIGINT NOT NULL
);

-- endregion
-- region: logic

CREATE OR REPLACE FUNCTION trebuchet.save_camel_card_game(inp text)
RETURNS BIGINT AS $$
    WITH new_game AS (
        INSERT INTO trebuchet.camel_card_game DEFAULT VALUES RETURNING *
    ),
    new_rounds AS (
        INSERT INTO trebuchet.camel_card_round (game_id, hand, bet)
        SELECT
            g.id,
            split[1] as hand,
            split[2]::bigint as bet
        FROM (
            SELECT
                ssv_to_array(value) as split,
                index AS round
            FROM lsv_to_table(inp)
            ORDER BY index
        ) t, LATERAL ( SELECT id FROM new_game LIMIT 1) g
        GROUP BY g.id, round, split[1], split[2]::bigint
    )
    SELECT id FROM new_game LIMIT 1

$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION trebuchet.card_hand_to_ranking(text)
RETURNS TABLE (hand text, combo_rank bigint, card_ranks bigint[]) AS $$
    WITH card_combo AS (
        SELECT *, (char_table(hand)).*
        FROM (
        SELECT
            $1 AS hand,
            array(SELECT (counter($1)).occurrences) as counts
        ) hc
    )
    SELECT
        hand,
        cch.rank AS combo_rank,
        array_agg(cca.rank) AS card_ranks
    FROM card_combo cc
    INNER JOIN trebuchet.camel_card cca ON
        cc.value = cca.label
    INNER JOIN trebuchet.camel_card_hand cch ON
        cc.counts = cch.combination
    GROUP BY hand, cch.rank

$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION trebuchet.rank_camel_card_rounds(game_id bigint)
RETURNS TABLE (hand text, bet bigint, rank bigint) AS $$
    SELECT
        hand,
        bet,
        row_number() OVER (
            ORDER BY (r.ranks).combo_rank, (r.ranks).card_ranks
        ) AS rank
    FROM (
        SELECT
            hand,
            bet,
            trebuchet.card_hand_to_ranking(ccr.hand) as ranks
        FROM trebuchet.camel_card_round ccr
        WHERE ccr.game_id = $1
    ) r

$$ LANGUAGE sql IMMUTABLE;

-- endregion

COMMIT;
