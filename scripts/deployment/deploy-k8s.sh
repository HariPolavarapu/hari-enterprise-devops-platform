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

NAMESPACE=${1:-hari-platform}
ENVIRONMENT=${2:-dev}

echo "Namespace: $NAMESPACE"
echo "Environment: $ENVIRONMENT"

echo ""
echo "Step 1: Creating namespace..."
kubectl create namespace $NAMESPACE || echo "Namespace already exists"

echo ""
echo "Step 2: Creating ConfigMaps and Secrets..."
kubectl create configmap app-config \
  --from-literal=ENVIRONMENT=$ENVIRONMENT \
  -n $NAMESPACE || echo "ConfigMap already exists"

echo ""
echo "Step 3: Deploying Helm charts..."
cd gitops/helm-charts

helm install employee-service ./employee-service \
  -n $NAMESPACE \
  --values ./employee-service/values-$ENVIRONMENT.yaml || true

helm install notification-service ./notification-service \
  -n $NAMESPACE \
  --values ./notification-service/values-$ENVIRONMENT.yaml || true

helm install payroll-service ./payroll-service \
  -n $NAMESPACE \
  --values ./payroll-service/values-$ENVIRONMENT.yaml || true

helm install frontend ./frontend \
  -n $NAMESPACE \
  --values ./frontend/values-$ENVIRONMENT.yaml || true

cd ../..

echo ""
echo "Step 4: Applying manifests..."
kubectl apply -f infrastructure/kubernetes/base/ -n $NAMESPACE
kubectl apply -f infrastructure/kubernetes/overlays/$ENVIRONMENT/ -n $NAMESPACE

echo ""
echo "=========================================="
echo "Kubernetes deployment completed!"
echo "=========================================="
echo ""
echo "Verify deployment:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get services -n $NAMESPACE"
echo "=========================================="
