-- Revert aoc-2023:day3-part1 from pg

BEGIN;

DROP FUNCTION IF EXISTS trebuchet.locate_engine_parts;
DROP FUNCTION IF EXISTS trebuchet.matrix_entry_has_adjacent_symbol;
DROP FUNCTION IF EXISTS trebuchet.save_engine_matrix;
DROP INDEX IF EXISTS trebuchet.idx_engine_matrix_entries_location;
DROP TABLE IF EXISTS trebuchet.engine_matrix_entries;
DROP TABLE IF EXISTS trebuchet.engine_matrix;
DROP EXTENSION IF EXISTS btree_gist CASCADE;

COMMIT;
