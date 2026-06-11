#!/bin/bash
# Development Setup Script

set -e

echo "=========================================="
echo "Setting up Development Environment"
echo "=========================================="

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not installed"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git not installed"
    exit 1
fi

echo "✓ Prerequisites met"
echo ""

# Create environment files
echo "Creating environment files..."

if [ ! -f ".env" ]; then
    cat > .env << EOF
# Development Environment Variables
ENVIRONMENT=dev
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=hari_dev

# API Configuration
API_PORT=8080
API_HOST=0.0.0.0

# Logging
LOG_LEVEL=DEBUG
EOF
    echo "✓ .env file created"
else
    echo "✓ .env file already exists"
fi

# Create logs directory
echo ""
echo "Creating log directories..."
mkdir -p logs
mkdir -p logs/services

echo "✓ Log directories created"

# Pull base images
echo ""
echo "Pulling Docker base images..."
docker pull postgres:16-alpine
docker pull node:20-alpine
docker pull openjdk:17-slim
docker pull mcr.microsoft.com/dotnet/sdk:8.0

echo "✓ Base images pulled"

echo ""
echo "=========================================="
echo "Development environment setup completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update .env file with your configuration"
echo "2. Run: bash scripts/deployment/deploy-dev.sh"
echo "3. Access: http://localhost:4200"
echo "=========================================="
