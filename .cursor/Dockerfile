FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        postgresql-client \
        docker.io \
        docker-compose-v2 \
    && rm -rf /var/lib/apt/lists/*
