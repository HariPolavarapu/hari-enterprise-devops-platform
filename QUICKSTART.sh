#!/bin/bash
# Quick Start Guide Script

echo "=========================================="
echo "Hari Enterprise DevOps Platform"
echo "Quick Start Guide"
echo "=========================================="
echo ""

echo "STEP 1: Setup Development Environment"
echo "--------------------------------------"
echo "Run: make setup"
echo ""

echo "STEP 2: Build All Services"
echo "---------------------------"
echo "Run: make build-all"
echo ""

echo "STEP 3: Deploy to Local Development"
echo "-------------------------------------"
echo "Run: make deploy-dev"
echo ""

echo "STEP 4: Access the Platform"
echo "----------------------------"
echo "Frontend:          http://localhost:4200"
echo "Employee Service:  http://localhost:8080"
echo "Notification Svc:  http://localhost:8081"
echo "Payroll Service:   http://localhost:8082"
echo ""

echo "USEFUL COMMANDS"
echo "==============="
echo "make help               - Show all available commands"
echo "make start              - Start all services"
echo "make stop               - Stop all services"
echo "make logs               - View logs"
echo "make health-check       - Check service health"
echo "make test               - Run tests"
echo "make clean              - Clean up containers"
echo ""

echo "TROUBLESHOOTING"
echo "==============="
echo "Docker not running?        - Start Docker Desktop"
echo "Ports already in use?      - Change ports in docker-compose.yml"
echo "Services not starting?     - Run: make logs"
echo "Database connection error? - Run: make db-init"
echo ""

echo "=========================================="
