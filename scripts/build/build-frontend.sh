#!/bin/bash
# Frontend Angular Build Script

set -e

echo "=========================================="
echo "Building Frontend Angular"
echo "=========================================="

cd applications/frontend-angular

echo "Step 1: Installing dependencies..."
npm install

echo "Step 2: Running linting..."
npm run lint || true

echo "Step 3: Running tests..."
npm test || true

echo "Step 4: Building for production..."
npm run build

echo "Step 5: Building Docker image..."
docker build -t hari-frontend:latest .

echo "=========================================="
echo "Frontend Angular build completed!"
echo "=========================================="
