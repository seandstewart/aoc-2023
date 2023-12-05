-- :name save :scalar
SELECT trebuchet.save_scratch_off_series(:values) AS id;
-- :name solve :scalar
SELECT sum(points)
FROM trebuchet.scratch_off
WHERE series_id = :id;
