#!/bin/bash
# Build All Services Script

set -e

echo "=========================================="
echo "Building All Services"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR/../")"

echo "Building Employee Service..."
bash scripts/build/build-employee-service.sh

echo ""
echo "Building Notification Service..."
bash scripts/build/build-notification-service.sh

echo ""
echo "Building Frontend..."
bash scripts/build/build-frontend.sh

echo ""
echo "Building Payroll Service..."
bash scripts/build/build-payroll-service.sh

echo "=========================================="
echo "All services built successfully!"
echo "=========================================="
