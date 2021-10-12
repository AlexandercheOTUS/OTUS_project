FROM python:3.6-alpine

WORKDIR /app
COPY . /app

RUN apk --no-cache --update add build-base && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    pip install --no-cache-dir -r /app/requirements-test.txt && \
    apk del build-base

# адрес mongodb-хоста
ENV MONGO mongodb
# порт для подключения к mongodb-хосту
ENV MONGO_PORT 27017

CMD cd ui && FLASK_APP=ui.py gunicorn ui:app -b 0.0.0.0
