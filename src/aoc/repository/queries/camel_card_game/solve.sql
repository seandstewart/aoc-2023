-- :name save :scalar
SELECT trebuchet.save_camel_card_game(:values) AS id;
-- :name solve :scalar
SELECT sum(bet * overall_rank)
FROM trebuchet.card_hand_to_ranking(:id);