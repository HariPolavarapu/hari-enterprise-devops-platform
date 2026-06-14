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

# Generate a secure random password for local development if not already provided.
# WARNING: This is auto-generated for local development only. Replace with a
# strong, unique password before deploying to any shared or production environment.
DB_PASSWORD="${DB_PASSWORD:-$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64 | tr -d '=+/'))}"

# Create environment files
echo "Creating environment files..."

if [ ! -f ".env" ]; then
    cat > .env << EOF
# Development Environment Variables
# WARNING: Never commit this file. It is generated for local development only.
ENVIRONMENT=dev
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=platform_dev

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
docker pull node:22-alpine
docker pull eclipse-temurin:17-jre-alpine
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
