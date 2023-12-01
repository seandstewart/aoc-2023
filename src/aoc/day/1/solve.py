#!/usr/bin/env python
from __future__ import annotations

from aoc import read
from aoc.repository import repository


def parse() -> str:
    return read.get_input(1)


def solve():
    calibrations = repository.CalibrationsRepository()
    values = parse()
    with calibrations.executor.transaction() as conn:
        saved = calibrations.save.execute(
            connection=conn,
            values=values
        )
        return calibrations.solve.execute(
            connection=conn,
            id=saved,
        )


if __name__ == "__main__":
    print(solve())
