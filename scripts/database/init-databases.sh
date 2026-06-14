#!/bin/bash
# Database Initialization Script

set -e

echo "=========================================="
echo "Initializing Databases"
echo "=========================================="

echo "Waiting for PostgreSQL to be ready..."
sleep 5

echo ""
echo "Creating databases..."

docker compose exec -T postgres psql -U "${DB_USER:-app_user}" -c "CREATE DATABASE employee_db;" || echo "employee_db already exists"
docker compose exec -T postgres psql -U "${DB_USER:-app_user}" -c "CREATE DATABASE notification_db;" || echo "notification_db already exists"
docker compose exec -T postgres psql -U "${DB_USER:-app_user}" -c "CREATE DATABASE payroll_db;" || echo "payroll_db already exists"

echo ""
echo "Databases initialized!"
echo ""

echo "Database Summary:"
docker compose exec -T postgres psql -U "${DB_USER:-app_user}" -l

echo ""
echo "=========================================="
