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
