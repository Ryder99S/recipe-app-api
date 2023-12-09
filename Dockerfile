# Aqui ponemos la version de la imagen que se quiere utilizar de python
FROM python:3.9-alpine3.13
LABEL maintiner="ridito99p"

#Esto le dice a Python que no desea almacenar en buffer la salida, haciendo esto mas rapida la app en docker
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000
ENV PYTHONPATH=/app

ARG DEV=false
RUN python -m venv /py && \
    source /py/bin/activate && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user

ENV PATH="/py/bin/:$PATH"

USER django-user