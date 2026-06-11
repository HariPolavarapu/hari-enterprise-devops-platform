#!/bin/bash
# Rollback Script

set -e

echo "=========================================="
echo "Rolling Back Deployment"
echo "=========================================="

ROLLBACK_VERSION=${1:-previous}
ENVIRONMENT=${2:-dev}

echo "Rolling back to version: $ROLLBACK_VERSION"
echo "Environment: $ENVIRONMENT"

if [ "$ROLLBACK_VERSION" = "docker-compose" ]; then
    echo ""
    echo "Stopping current deployment..."
    docker-compose down
    
    echo ""
    echo "Starting previous deployment..."
    docker-compose -f docker-compose.${ENVIRONMENT}.yml up -d
    
elif [ "$ROLLBACK_VERSION" = "kubernetes" ]; then
    NAMESPACE=${3:-hari-platform}
    
    echo ""
    echo "Rolling back Kubernetes deployments in namespace: $NAMESPACE"
    
    kubectl rollout undo deployment/employee-service -n $NAMESPACE || true
    kubectl rollout undo deployment/notification-service -n $NAMESPACE || true
    kubectl rollout undo deployment/payroll-service -n $NAMESPACE || true
    kubectl rollout undo deployment/frontend -n $NAMESPACE || true
    
    echo ""
    echo "Waiting for rollback to complete..."
    sleep 10
fi

echo ""
echo "=========================================="
echo "Rollback completed!"
echo "=========================================="
