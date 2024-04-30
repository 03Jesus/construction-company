FROM python:3.11.8-alpine

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /app/requirements.txt

# install psycopg2 dependencies

RUN apk update
RUN apk add postgresql-dev gcc python3-dev musl-dev

# install dependencies

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]