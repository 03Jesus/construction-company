from sqlmodel import Field, SQLModel
from datetime import date


class ClientBase(SQLModel):
    name: str = Field(index=True)
    last_name: str = Field(index=True)
    phone: str | None = Field(default=None)
    email: str | None = Field(default=None)


class Client(ClientBase, table=True):
    id: int = Field(default=None, primary_key=True)


class ClientCreate(ClientBase):
    pass


class ClientPublic(ClientBase):
    id: int


class ClientUpdate(SQLModel):
    name: str | None = None
    last_name: str | None = None
    phone: str | None = None
    email: str | None = None
