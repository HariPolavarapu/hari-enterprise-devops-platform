#!/bin/bash
# Kubernetes Deployment Script

set -e

echo "=========================================="
echo "Deploying to Kubernetes"
echo "=========================================="

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl."
    exit 1
fi

NAMESPACE=${1:-enterprise-platform}
ENVIRONMENT=${2:-dev}

echo "Namespace: $NAMESPACE"
echo "Environment: $ENVIRONMENT"

echo ""
echo "Step 1: Creating namespace..."
kubectl create namespace $NAMESPACE || echo "Namespace already exists"

echo ""
echo "Step 2: Rendering and deploying Helm charts..."
for chart in employee-service notification-service payroll-service frontend; do
  helm upgrade --install "$chart" "gitops/helm-charts/$chart" \
    --namespace "$NAMESPACE" \
    --set-string environment.name="$ENVIRONMENT" \
    --wait --timeout 5m
done

echo ""
echo "=========================================="
echo "Kubernetes deployment completed!"
echo "=========================================="
echo ""
echo "Verify deployment:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get services -n $NAMESPACE"
echo "=========================================="
