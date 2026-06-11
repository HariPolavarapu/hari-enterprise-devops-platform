#!/bin/bash
# Production Deployment Script

set -e

echo "=========================================="
echo "Deploying Hari DevOps Platform (Production)"
echo "=========================================="

# Check required environment variables
if [ -z "$DOCKER_REGISTRY" ]; then
    echo "Error: DOCKER_REGISTRY environment variable not set"
    exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "Error: DB_PASSWORD environment variable not set"
    exit 1
fi

echo "Step 1: Building services..."
bash scripts/build/build-all.sh

echo ""
echo "Step 2: Tagging Docker images for registry..."
docker tag hari-employee-service:latest $DOCKER_REGISTRY/hari-employee-service:latest
docker tag hari-notification-service:latest $DOCKER_REGISTRY/hari-notification-service:latest
docker tag hari-payroll-service:latest $DOCKER_REGISTRY/hari-payroll-service:latest
docker tag hari-frontend:latest $DOCKER_REGISTRY/hari-frontend:latest

echo ""
echo "Step 3: Pushing images to registry..."
docker push $DOCKER_REGISTRY/hari-employee-service:latest
docker push $DOCKER_REGISTRY/hari-notification-service:latest
docker push $DOCKER_REGISTRY/hari-payroll-service:latest
docker push $DOCKER_REGISTRY/hari-frontend:latest

echo ""
echo "Step 4: Deploying with Docker Compose..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "=========================================="
echo "Production deployment completed!"
echo "=========================================="
