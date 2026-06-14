#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env. Set DB_PASSWORD, then rerun this script."
  exit 1
fi

docker compose up --build -d
docker compose ps
