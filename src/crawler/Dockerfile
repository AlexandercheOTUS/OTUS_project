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
# адрес rabbitmq-хоста
ENV RMQ_HOST rabbitmq
# имя очереди rabbitmq
ENV RMQ_QUEUE rabbitmq
# пользователь для подключения к rabbitmq-серверу
ENV RMQ_USERNAME rabbitmq
# пароль пользователя
ENV RMQ_PASSWORD rabbitmq
# минимальное время между повторными проверками одного и того же url
ENV CHECK_INTERVAL 90
# адреса которые будут исключены из обхода записанные через запятую в формате простых регулярных выражений
ENV EXCLUDE_URLS '.*github.com'

CMD ["sh","-c","EXCLUDE_URLS='.*github.com' python -u crawler/crawler.py https://vitkhab.github.io/search_engine_test_site/"]
