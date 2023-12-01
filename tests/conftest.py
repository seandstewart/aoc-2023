import pytest

import yesql
import psycopg


from src.repository import repository



@pytest.fixture()
def executor() -> yesql.drivers.postgresql.SyncQueryExecutor:
    executor = yesql.drivers.postgresql.SyncQueryExecutor()
    return executor


@pytest.fixture
def session(executor) -> psycopg.Connection:
    with executor.transaction(rollback=True) as connection:
        yield connection


@pytest.fixture
def meals_repository(executor) -> repository.MealsRepository:
    repo = repository.MealsRepository(executor=executor)
    return repo


@pytest.fixture
def elves_repository(executor) -> repository.ElvesRepository:
    repo = repository.ElvesRepository(executor=executor)
    return repo


@pytest.fixture
def tournament_repository(executor):
    repo = repository.TournamentRepository(executor=executor)
    return repo
