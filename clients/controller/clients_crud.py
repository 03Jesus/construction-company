from fastapi import HTTPException
from db.models import Client, ClientCreate, ClientUpdate
from sqlmodel import Session, select
from db.db import engine

from os import getenv
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
from dotenv import load_dotenv

load_dotenv()

conn_str = getenv("SERVICE_BUS_CONN_STR")
queue_name = getenv("SERVICE_BUS_QUEUE_NAME")


async def send_message_to_queue(sender, message: str):
    # Create a Service Bus message and send it to the queue
    message = ServiceBusMessage(message)
    await sender.send_messages(message)
    print(f"Sending message: {message}")


async def get_clients():
    try:
        with Session(engine) as session:
            clients = session.exec(select(Client)).all()
            return clients
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def get_client_by_id(client_id: int):
    with Session(engine) as session:
        client = session.get(Client, client_id)
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")
        return client


async def create_client(client: ClientCreate):
    try:
        with Session(engine) as session:
            db_client = Client.model_validate(client)
            session.add(db_client)
            session.commit()
            session.refresh(db_client)

            async with ServiceBusClient.from_connection_string(
                conn_str, logging_enable=True
            ) as client:
                async with client.get_queue_sender(queue_name=queue_name) as sender:
                    await send_message_to_queue(
                        sender=sender, message=f"{db_client.email},{db_client.name}"
                    )

            return db_client
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def update_client(client_id: int, client: ClientUpdate):
    with Session(engine) as session:
        db_client = session.get(Client, client_id)
        if not db_client:
            raise HTTPException(status_code=404, detail="Client not found")
        client_data = client.model_dump(exclude_unset=True)
        db_client.sqlmodel_update(client_data)
        session.add(db_client)
        session.commit()
        session.refresh(db_client)
        return db_client


async def delete_client(client_id: int):
    with Session(engine) as session:
        client = session.get(Client, client_id)
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")
        session.delete(client)
        session.commit()
        return {"message": "Client deleted"}
