-- :name save :scalar
SELECT trebuchet.save_engine_matrix(:values) AS id;
-- :name solve :scalar
SELECT sum(part::bigint) FROM (
    SELECT * FROM
    trebuchet.locate_engine_parts(:id)
    AS parts(part)
) p;
