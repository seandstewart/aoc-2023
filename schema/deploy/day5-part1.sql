-- Deploy aoc-2023:day5-part1 to pg
-- requires: init

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS trebuchet.seed_map_series (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS trebuchet.seed (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    series_id BIGINT NOT NULL
        REFERENCES trebuchet.seed_map_series(id) ON DELETE CASCADE,
    number BIGINT NOT NULL
);
CREATE TABLE IF NOT EXISTS trebuchet.seed_mapping (
    id BIGINT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    series_id BIGINT NOT NULL
        REFERENCES trebuchet.seed_map_series(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    line BIGINT NOT NULL,
    grouping BIGINT NOT NULL,
    index BIGINT NOT NULL,
    source BIGINT NOT NULL,
    destination BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_seed_mapping_sort ON trebuchet.seed_mapping(
    line ASC, grouping ASC, index ASC
);

-- endregion
-- region: logic

CREATE OR REPLACE FUNCTION trebuchet.save_seed_mappings(value text)
RETURNS BIGINT AS $$
    WITH input_split AS (
        SELECT regexp_split_to_table(value, E'\\n{2}[[:space:]]*') as raw_tables
    ),
    tables AS (
        SELECT regexp_split_to_array(
            raw_tables,
            E'(?: map)?:[[:space:]]+'
        ) as table_parts
        FROM input_split
        WHERE raw_tables != ''
    ),
    given_seeds AS (
        SELECT regexp_split_to_table(table_parts[2], '[[:space:]]+')::bigint AS number
        FROM tables
        WHERE table_parts[1] = 'seeds'
        AND array_length(table_parts, 1) = 2
    ),
    given_map_configs AS (
        SELECT
            table_parts[1] as category,
            regexp_split_to_array(
               regexp_split_to_table(table_parts[2], E'\\n+[[:space:]]+'), '[[:space:]]+'
            )::bigint[] as map_range_config
        FROM tables
        WHERE table_parts[1] != 'seeds'
        AND array_length(table_parts, 1) = 2
    ),
    given_map_configs_positions AS (
        SELECT
            category,
            row_number() over () as line,
            map_range_config
        FROM given_map_configs
    ),
    given_maps_exploded AS (
        SELECT
            category,
            line,
            'destination' as location,
            generate_series(
                map_range_config[1], map_range_config[3] + map_range_config[1] - 1
            ) as number,
            generate_series(1, map_range_config[3]) AS index,
            row_number() over (partition by category order by line) as grouping
        FROM given_map_configs_positions
        UNION ALL
        SELECT
            category,
            line,
            'source' as location,
            generate_series(
                map_range_config[2], map_range_config[3] + map_range_config[2] - 1
            ) as number,
            generate_series(1, map_range_config[3]) AS index,
            row_number() over (partition by category order by line) as grouping
        FROM given_map_configs_positions
        ORDER BY category, line, number
    ),
    given_maps_flattened AS (
        SELECT
            gme_dest.category,
            gme_dest.line,
            gme_dest.grouping,
            gme_dest.index,
            gme_dest.number as destination,
            gme_src.number as source
        FROM given_maps_exploded gme_dest
        INNER JOIN given_maps_exploded gme_src
            ON gme_dest.grouping = gme_src.grouping
            AND gme_dest.category = gme_src.category
            AND gme_dest.index = gme_src.index
            AND gme_dest.location = 'destination'
            AND gme_src.location = 'source'
    ),
    series AS (INSERT INTO trebuchet.seed_map_series DEFAULT VALUES RETURNING *),
    seeds AS (
        INSERT INTO trebuchet.seed
            SELECT
                s.id,
                given_seeds.*
            FROM given_seeds, LATERAL (SELECT id FROM series LIMIT 1) s
    ),
    seed_maps AS (
        INSERT INTO trebuchet.seed_mapping
            SELECT
                s.id,
                given_maps_flattened.*
            FROM given_maps_flattened, LATERAL (SELECT id FROM series LIMIT 1) s
    )
    SELECT id FROM series LIMIT 1

$$ LANGUAGE sql;

-- endregion

COMMIT;
