#!/bin/bash
# Notification Python Service Build Script

set -e

echo "=========================================="
echo "Building Notification Python Service"
echo "=========================================="

cd applications/notification-python-service

echo "Step 1: Creating virtual environment..."
python -m venv venv
source venv/bin/activate

echo "Step 2: Installing dependencies..."
pip install -r requirements.txt

echo "Step 3: Running tests..."
pytest tests/ || true

echo "Step 4: Building Docker image..."
docker build -t notification-service:local .

echo "=========================================="
echo "Notification Python Service build completed!"
echo "=========================================="
