-- :name save :scalar
SELECT trebuchet.save_camel_card_game(:values) AS id;
-- :name solve :scalar
SELECT sum(bet * rank)
FROM trebuchet.rank_camel_card_rounds(:id);