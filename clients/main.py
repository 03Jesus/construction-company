from contextlib import asynccontextmanager
from fastapi import FastAPI
from db.db import create_db_and_tables
from routes.clients import client_router
from fastapi.middleware.cors import CORSMiddleware


@asynccontextmanager
async def app_lifespan(app: FastAPI):
    # code to execute when app is starting up
    create_db_and_tables()
    yield
    # code to execute when app is shutting down
    print("Shutting down app")


app = FastAPI(lifespan=app_lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(client_router)


@app.get("/")
def read_root():
    return {"Clients": "Microservice is running"}
