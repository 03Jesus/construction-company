from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from db.db import create_db_and_tables

from routes.projects import project_router


@asynccontextmanager
async def app_lifespan(app: FastAPI):
    # code to execute when app is starting up
    create_db_and_tables()
    yield
    # code to execute when app is shutting down
    print("Shutting down app")


app = FastAPI(version="0.0.2", lifespan=app_lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(project_router)


@app.get("/")
def read_root():
    return {"Projects": "Microservice is running"}
