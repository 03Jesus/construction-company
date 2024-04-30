from sqlmodel import Field, SQLModel
from datetime import date


class ProjectBase(SQLModel):
    name: str = Field(index=True)
    description: str | None = Field(default=None)
    budget: float | None = Field(default=None)
    start_date: date | None = Field(default=None)
    estimated_end_date: date | None = Field(default=None)
    real_end_date: date | None = Field(default=None)
    is_active: bool = Field(default=True)
    owner_id: int | None = Field(default=None)


class Project(ProjectBase, table=True):
    id: int | None = Field(default=None, primary_key=True)


class ProjectCreate(ProjectBase):
    pass


class ProjectPublic(ProjectBase):
    id: int


class ProjectUpdate(SQLModel):
    name: str | None = None
    description: str | None = None
    budget: float | None = None
    start_date: date | None = None
    estimated_end_date: date | None = None
    real_end_date: date | None = None
    is_active: bool | None = None
    owner_id: int | None = None
