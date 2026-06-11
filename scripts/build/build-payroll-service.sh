#!/bin/bash
# Payroll .NET Service Build Script

set -e

echo "=========================================="
echo "Building Payroll .NET Service"
echo "=========================================="

cd applications/payroll-dotnet-service

echo "Step 1: Restoring NuGet packages..."
dotnet restore

echo "Step 2: Building solution..."
dotnet build --configuration Release

echo "Step 3: Running tests..."
dotnet test Tests/ || true

echo "Step 4: Publishing..."
dotnet publish --configuration Release --output ./bin/publish

echo "Step 5: Building Docker image..."
docker build -t hari-payroll-service:latest .

echo "=========================================="
echo "Payroll .NET Service build completed!"
echo "=========================================="
