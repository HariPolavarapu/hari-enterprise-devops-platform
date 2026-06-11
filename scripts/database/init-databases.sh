#!/bin/bash
# Database Initialization Script

set -e

echo "=========================================="
echo "Initializing Databases"
echo "=========================================="

POSTGRES_CONTAINER="hari-postgres"

echo "Waiting for PostgreSQL to be ready..."
sleep 5

echo ""
echo "Creating databases..."

docker exec $POSTGRES_CONTAINER psql -U postgres -c "CREATE DATABASE employee_db;" || echo "employee_db already exists"
docker exec $POSTGRES_CONTAINER psql -U postgres -c "CREATE DATABASE notification_db;" || echo "notification_db already exists"
docker exec $POSTGRES_CONTAINER psql -U postgres -c "CREATE DATABASE payroll_db;" || echo "payroll_db already exists"

echo ""
echo "Databases initialized!"
echo ""

echo "Database Summary:"
docker exec $POSTGRES_CONTAINER psql -U postgres -l | grep hari

echo ""
echo "=========================================="
