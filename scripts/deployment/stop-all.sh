#!/bin/bash
# Stop All Services

set -e

echo "Stopping all services..."

if [ "$1" = "-v" ] || [ "$1" = "--volumes" ]; then
    echo "Stopping and removing volumes..."
    docker-compose down -v
else
    echo "Stopping services..."
    docker-compose down
fi

echo "All services stopped."
