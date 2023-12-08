-- Revert aoc-2023:day7-part2 from pg

BEGIN;

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

DROP FUNCTION IF EXISTS trebuchet.card_hand_to_ranking(bigint);


COMMIT;
