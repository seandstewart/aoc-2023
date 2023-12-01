-- :name save :scalar
SELECT trebuchet.save_calibration_values(:values) AS id;
-- :name solve :scalar
SELECT sum(value) FROM trebuchet.calibration_value cv
WHERE cv.calibration_attempt_id = :id;
