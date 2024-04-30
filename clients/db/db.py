from sqlmodel import SQLModel, create_engine
from . import models

from dotenv import load_dotenv
import os

load_dotenv()

db_url = os.getenv("DEVELOPMENT_DATABASE_URL")

engine = create_engine(db_url, echo=True)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
