-- :name save :scalar
SELECT trebuchet.save_cube_game_series(:values) AS id;
-- :name solve :scalar
SELECT sum(number) FROM (
    SELECT cg.number
    FROM trebuchet.cube_game cg
    INNER JOIN trebuchet.cube_game_round c on cg.id = c.game_id
    WHERE cg.series_id = :id
    GROUP BY cg.number
    HAVING
        max(c.blue) <= 14
        AND max(c.green) <= 13
        AND max(c.red) <= 12
) numbers;
-- :name solve_part_two :scalar
SELECT sum(power) FROM (
    SELECT
        cg.number,
        max(c.blue) * max(c.green) * max(c.red) as power
    FROM trebuchet.cube_game cg
    INNER JOIN trebuchet.cube_game_round c on cg.id = c.game_id
    WHERE cg.series_id = :id
    GROUP BY cg.number

) powers