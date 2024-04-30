from fastapi import APIRouter
from db.models import ClientCreate, ClientUpdate, ClientPublic
import controller.clients_crud as clients_crud

client_router = APIRouter(
    prefix="/clients",
    tags=["clients"],
)


@client_router.get("/", response_model=list[ClientPublic])
async def read_clients():
    return await clients_crud.get_clients()


@client_router.get("/{client_id}", response_model=ClientPublic)
async def read_client(client_id: int):
    return await clients_crud.get_client_by_id(client_id)


@client_router.post("/", response_model=ClientPublic)
async def create_client(client: ClientCreate):
    return await clients_crud.create_client(client)


@client_router.put("/{client_id}", response_model=ClientPublic)
async def update_client(client_id: int, client: ClientUpdate):
    return await clients_crud.update_client(client_id, client)


@client_router.delete("/{client_id}")
async def delete_client(client_id: int):
    return await clients_crud.delete_client(client_id)
