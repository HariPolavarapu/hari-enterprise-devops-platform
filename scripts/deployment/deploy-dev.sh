#!/bin/bash
# Local Development Deployment Script

set -e

echo "=========================================="
echo "Deploying Hari DevOps Platform (Development)"
echo "=========================================="

# Check Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

echo "Step 1: Building all services..."
bash scripts/build/build-all.sh

echo ""
echo "Step 2: Starting services with Docker Compose..."
docker-compose -f docker-compose.yml up -d

echo ""
echo "Step 3: Waiting for services to be healthy..."
sleep 10

echo ""
echo "=========================================="
echo "Deployment completed!"
echo "=========================================="
echo ""
echo "Access the application:"
echo "  Frontend: http://localhost:4200"
echo "  Employee Service: http://localhost:8080"
echo "  Notification Service: http://localhost:8081"
echo "  Payroll Service: http://localhost:8082"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo "=========================================="
