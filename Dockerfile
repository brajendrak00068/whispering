FROM python:3.10-slim

ENV POETRY_VENV=/app/.venv

RUN apt-get  update

RUN apt -y install portaudio19-dev

RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry

ENV PATH="${PATH}:${POETRY_VENV}/bin"

WORKDIR /app

COPY . /app

RUN poetry config virtualenvs.in-project true
RUN poetry install

ENTRYPOINT ["whispering", "--language", "en", "--model", "tiny", "--host", "0.0.0.0", "--port", "8000"]