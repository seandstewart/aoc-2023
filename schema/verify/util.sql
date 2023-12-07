-- Verify aoc-2023:util on pg

BEGIN;

DO $$
    DECLARE given_input text;
    DECLARE expected_output jsonb;
    DECLARE found_output jsonb;
    BEGIN
        -- Given
        given_input := 'AAABBC';
        expected_output := '[{"value":"A","occurrences":3},{"value":"B","occurrences":2},{"value":"C","occurrences":1}]';
        -- When
        found_output := to_jsonb(array(SELECT counter(given_input)));
        -- Then
        ASSERT found_output @> expected_output AND found_output <@ expected_output,
            'Expectation failed: '
            || found_output::text || ' != ' || expected_output::text;
    END;
$$;
DO $$
    DECLARE given_input text;
    DECLARE expected_int_array bigint[];
    DECLARE found_int_array bigint[];
    BEGIN
        -- Given
        given_input := '1 2w34.';
        expected_int_array := ARRAY [1,2,34];
        -- When
        found_int_array := int_array(given_input);
        -- Then
        ASSERT found_int_array = expected_int_array,
            'Expectation failed: '
            || found_int_array::text || ' != ' || expected_int_array::text;
    END;
$$;
DO $$
    DECLARE given_input text;
    DECLARE expected_output jsonb;
    DECLARE found_output jsonb;
    BEGIN
        -- Given
        given_input := '1 2w34.';
        expected_output := '[{"value":1,"index":1},{"value":2,"index":2},{"value":34,"index":3}]';
        -- When
        found_output := to_jsonb(array(SELECT int_table(given_input)));
        -- Then
        ASSERT found_output @> expected_output AND found_output <@ expected_output,
            'Expectation failed: '
            || found_output::text || ' != ' || expected_output::text;
    END;
$$;
DO $$
    DECLARE given_input text;
    DECLARE expected_output jsonb;
    DECLARE found_output jsonb;
    BEGIN
        -- Given
        given_input := 'foo: bar';
        expected_output := '{"label":"foo","value":"bar"}';
        -- When
        found_output := to_jsonb(labeled(given_input));
        -- Then
        ASSERT found_output @> expected_output AND found_output <@ expected_output,
            'Expectation failed: '
            || found_output::text || ' != ' || expected_output::text;
    END;
$$;
DO $$
    DECLARE given_input text;
    DECLARE expected_output jsonb;
    DECLARE found_output jsonb;
    BEGIN
        -- Given
        given_input :=     '
        one
        two
        ';
        expected_output := '[{"value":"one","index":1},{"value":"two","index":2}]';
        -- When
        found_output := to_jsonb(array(SELECT lsv_to_table(given_input)));
        -- Then
        ASSERT found_output @> expected_output AND found_output <@ expected_output,
            'Expectation failed: '
            || found_output::text || ' != ' || expected_output::text;
    END;
$$;


ROLLBACK;
