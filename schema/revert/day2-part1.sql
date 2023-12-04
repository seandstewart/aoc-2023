-- Revert aoc-2023:day2-part1 from pg

BEGIN;

DROP FUNCTION IF EXISTS trebuchet.save_cube_game_series CASCADE;
DROP INDEX IF EXISTS trebuchet.idx_cube_game_round_colors CASCADE;
DROP TABLE IF EXISTS trebuchet.cube_game_round CASCADE;
DROP INDEX IF EXISTS trebuchet.uidx_cube_game_series_name CASCADE;
DROP TABLE IF EXISTS trebuchet.cube_game CASCADE;
DROP TABLE IF EXISTS trebuchet.cube_game_series CASCADE;

COMMIT;
