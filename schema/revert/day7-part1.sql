-- Revert aoc-2023:day7-part1 from pg

BEGIN;

DROP FUNCTION IF EXISTS trebuchet.rank_camel_card_rounds;
DROP FUNCTION IF EXISTS trebuchet.card_hand_to_ranking;
DROP FUNCTION IF EXISTS trebuchet.save_camel_card_game;
DROP TABLE IF EXISTS trebuchet.camel_card_round;
DROP TABLE IF EXISTS trebuchet.camel_card_game;
DROP TABLE IF EXISTS trebuchet.camel_card_hand;
DROP TABLE IF EXISTS trebuchet.camel_card;

COMMIT;
