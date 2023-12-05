from __future__ import annotations

import pathlib

import yesql


class BaseMetadata(yesql.QueryMetadata):
    __dialect__ = "postgresql"
    __querylib__ = pathlib.Path(__file__).parent.resolve() / "queries"


class CalibrationsRepository(yesql.SyncQueryRepository):

    class metadata(BaseMetadata):
        __tablename__ = "calibration_attempt"

    save: yesql.Statement
    solve: yesql.Statement


class CubeGameSeriesRepository(yesql.SyncQueryRepository):

    class metadata(BaseMetadata):
        __tablename__ = "cube_game_series"

    save: yesql.Statement
    solve: yesql.Statement
    solve_part_two: yesql.Statement


class EngineMatrixRepository(yesql.SyncQueryRepository):

    class metadata(BaseMetadata):
        __tablename__ = "engine_matrix"

    save: yesql.Statement
    solve: yesql.Statement
    solve_part_two: yesql.Statement


class ScratchOffRepository(yesql.SyncQueryRepository):

    class metadata(BaseMetadata):
        __tablename__ = "scratch_off"

    save: yesql.Statement
    solve: yesql.Statement
    solve_part_two: yesql.Statement
