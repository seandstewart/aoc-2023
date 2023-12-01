import pytest

import yesql
import psycopg


@pytest.fixture()
def executor() -> yesql.drivers.postgresql.SyncQueryExecutor:
    executor = yesql.drivers.postgresql.SyncQueryExecutor()
    return executor


@pytest.fixture
def session(executor) -> psycopg.Connection:
    with executor.transaction(rollback=True) as connection:
        yield connection
