-- Deploy aoc-2023:day2-part1 to pg
-- requires: init

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS trebuchet.cube_game_series (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS trebuchet.cube_game (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    series_id BIGINT NOT NULL
        REFERENCES trebuchet.cube_game_series(id) ON DELETE CASCADE,
    number BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX IF NOT EXISTS uidx_cube_game_series_name
    ON trebuchet.cube_game(series_id, number);

CREATE TABLE IF NOT EXISTS trebuchet.cube_game_round (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    game_id BIGINT NOT NULL REFERENCES trebuchet.cube_game (id) ON DELETE CASCADE,
    red BIGINT NOT NULL,
    blue BIGINT NOT NULL,
    green BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_cube_game_round_colors
    ON trebuchet.cube_game_round( red, blue, green) ;

-- endregion
-- region: logic

CREATE OR REPLACE FUNCTION trebuchet.save_cube_game_series("value" text)
RETURNS BIGINT AS $$
    WITH new_series AS (
        INSERT INTO trebuchet.cube_game_series DEFAULT VALUES RETURNING *
    ), game_rounds_parsed AS (
        SELECT
            gr.game_number,
            gr.game_round_number,
            jsonb_object(
                array(
                    SELECT * FROM unnest(
                    array_agg( ARRAY [gr.cube_pair[2], gr.cube_pair[1]])))
            ) as color_counts
        FROM (
            SELECT
                row_number() over (ORDER BY null) AS game_round_number,
                gg.game_number,
                string_to_array(
                    string_to_table(gg.game_round, ', '), ' '
                ) AS cube_pair
            FROM (
                SELECT
                    ((regexp_match(g.parts[1], '[[:digit:]]+'))[1])::bigint AS game_number,
                    string_to_table(g.parts[2], '; ') AS game_round
                FROM (
                    SELECT
                        string_to_array(regexp_split_to_table("value", E'\\n+'), ': ') parts
                    ) g
                    WHERE array_length(g.parts, 1) = 2
            ) gg
        ) gr
        GROUP BY (gr.game_number, gr.game_round_number)
    ), new_games AS (
        INSERT INTO trebuchet.cube_game (series_id, number)
        SELECT DISTINCT ns.id, p.game_number
        FROM game_rounds_parsed p, LATERAL (
            SELECT id FROM new_series LIMIT 1
        ) ns
        ON CONFLICT (series_id, number) DO NOTHING
        RETURNING *
    ), new_game_rounds AS (
        INSERT INTO trebuchet.cube_game_round (game_id, blue, red, green)
        SELECT
            ng.id,
            (coalesce(grp.color_counts->>'blue', '0'))::bigint,
            (coalesce(grp.color_counts->>'red', '0'))::bigint,
            (coalesce(grp.color_counts->>'green', '0'))::bigint
        FROM game_rounds_parsed grp
        INNER JOIN new_games ng ON ng.number = grp.game_number
    )
    SELECT new_series.id FROM new_series
$$ LANGUAGE sql;

COMMIT;
