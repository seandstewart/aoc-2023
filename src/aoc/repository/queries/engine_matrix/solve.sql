-- :name save :scalar
SELECT trebuchet.save_engine_matrix(:values) AS id;
-- :name solve :scalar
SELECT sum(part::bigint) FROM (
    SELECT * FROM
    trebuchet.locate_engine_parts(:id)
    AS parts(part)
) p;
-- :name solve_part_two :scalar
SELECT sum(ratio::bigint) FROM (
    SELECT * FROM
    trebuchet.calculate_gear_ratios(:id)
    AS ratios(ratio)
) p
