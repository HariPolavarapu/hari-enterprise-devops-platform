#!/bin/bash
# Health Check Script

set -e

echo "=========================================="
echo "Health Check - Enterprise DevOps Platform"
echo "=========================================="

SERVICES=(
    "http://localhost:8080/api/actuator/health"
    "http://localhost:8081/health"
    "http://localhost:8082/api/health"
    "http://localhost:4200"
)

echo "Checking services..."
echo ""

for service in "${SERVICES[@]}"; do
    echo -n "Checking $service ... "
    if curl -s -o /dev/null -w "%{http_code}" "$service" | grep -q "200"; then
        echo "✓ OK"
    else
        echo "✗ FAILED"
    fi
done

echo ""
echo "Docker container status:"
docker-compose ps

echo ""
echo "Database connection:"
docker compose exec -T postgres pg_isready -U "${DB_USER:-app_user}" || echo "Cannot connect to database"

echo ""
echo "=========================================="
echo "Health check completed!"
echo "=========================================="
