#!/usr/bin/env python
from __future__ import annotations

from aoc import read
from aoc.repository import repository


def parse() -> str:
    return read.get_input(3)


def solve():
    engines = repository.EngineMatrixRepository()
    values = parse()
    with engines.executor.transaction() as conn:
        saved = engines.save.execute(
            connection=conn,
            values=values
        )
        return engines.solve.execute(
            connection=conn,
            id=saved,
        )


if __name__ == "__main__":
    print(solve())
