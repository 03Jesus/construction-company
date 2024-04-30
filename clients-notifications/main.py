from os import getenv
from dotenv import load_dotenv
import asyncio
from azure.servicebus.aio import ServiceBusClient
from time import sleep

load_dotenv()

conn_str = getenv("SERVICE_BUS_CONN_STR")
queue_name = getenv("SERVICE_BUS_QUEUE_NAME")
resend_api_key = getenv("RESEND_API_KEY")


async def main():
    async with ServiceBusClient.from_connection_string(
        conn_str=conn_str, logging_enable=True
    ) as client:
        async with client.get_queue_receiver(queue_name) as receiver:
            while True:
                messages = await receiver.receive_messages(max_message_count=20)
                for message in messages:
                    message_str = str(message)
                    print(f"Received: {message_str}")
                    email, name = message_str.split(",")
                    try:
                        await send_email(email, name)
                    except Exception as e:
                        print(e)
                    await receiver.complete_message(message)
                    print(f"Completed: {message}")
                sleep(5)


async def send_email(email: str, name: str):
    import yagmail

    from_email = getenv("GMAIL_ADDRESS")
    password = getenv("GMAIL_API_KEY")

    yag = yagmail.SMTP(user=from_email, password=password)
    yag.send(
        to=email,
        subject="Construction Company Registration",
        contents=f"Hello <strong>{name}</strong>, your registration to UTB Construction Company has been successful!",
    )


asyncio.run(main())
