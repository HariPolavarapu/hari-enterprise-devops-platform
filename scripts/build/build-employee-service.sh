#!/bin/bash
# Employee Java Service Build Script

set -e

echo "=========================================="
echo "Building Employee Java Service"
echo "=========================================="

cd applications/employee-java-service

echo "Step 1: Cleaning previous builds..."
mvn clean

echo "Step 2: Building with Maven..."
mvn package -DskipTests

echo "Step 3: Building Docker image..."
docker build -t hari-employee-service:latest .

echo "=========================================="
echo "Employee Java Service build completed!"
echo "=========================================="
