# ArgoCD Setup and Application Reference

GitOps continuous delivery configuration for the Hari Enterprise DevOps Platform using ArgoCD. All Kubernetes workloads are managed declaratively through Git — ArgoCD syncs the cluster state from the Git repository.

## Architecture Overview

```
Git Repository (main branch)
    │
    ├── gitops/helm-charts/   ← Helm chart definitions per service
    │
    └── gitops/argocd/{dev,test,prod}/  ← ArgoCD Application manifests
              │
              ▼
         ArgoCD Controller
              │
              ▼
         Kubernetes Cluster
```

## Repository Configuration

Before bootstrapping ArgoCD, update the `repoURL` in each Application manifest to point to the public Git repository:

```
https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git
```

Repository credentials (if required for private repos) must be stored in ArgoCD's Secret management. **Do not commit credentials to this repository.**

## Application Structure

Each environment (`dev`, `test`, `prod`) has its own directory under `/gitops/argocd/` containing ArgoCD Application manifests for all four services:

| Service | Application Name (dev) | Application Name (test) | Application Name (prod) |
|---------|----------------------|----------------------|----------------------|
| Employee Service | `employee-service-dev` | `employee-service-test` | `employee-service-prod` |
| Notification Service | `notification-service-dev` | `notification-service-test` | `notification-service-prod` |
| Payroll Service | `payroll-service-prod` | `payroll-service-test` | `payroll-service-prod` |
| Frontend | `frontend-dev` | `frontend-test` | `frontend-prod` |

### Application Manifest Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: employee-service-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git
    targetRevision: main
    path: gitops/helm-charts/employee-service
    helm:
      values: |
        environment: dev
        replicaCount: 1
        image:
          tag: dev-latest
  destination:
    server: https://kubernetes.default.svc
    namespace: enterprise-platform-dev
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
    syncOptions:
      - CreateNamespace=true
  revisionHistoryLimit: 10
```

## Environment Namespaces

| Namespace | Environment | ArgoCD Project |
|-----------|------------|---------------|
| `enterprise-platform-dev` | Development | `default` (auto-sync) |
| `enterprise-platform-test` | Test / Staging | `default` (auto-sync) |
| `enterprise-platform` | Production | `default` (manual sync) |
| `argocd` | ArgoCD system | — |

The `enterprise-platform` namespace is created with restricted Pod Security Standards enforced:

```yaml
metadata:
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Sync Policies

### Development (`dev`)
- **Automated sync**: Enabled
- **Prune**: Disabled (prevents accidental deletion of resources)
- **Self-heal**: Disabled
- **Revision history**: 10 revisions retained

### Test (`test`)
- **Automated sync**: Enabled
- **Trivy scan gate**: Image must pass `HIGH/CRITICAL` scan in CI before push
- **Prune**: Disabled
- **Revision history**: 10 revisions retained

### Production (`prod`)
- **Automated sync**: Disabled — manual sync required
- **Approval**: Requires platform owner approval before syncing
- **Prune**: Enabled
- **Revision history**: 10 revisions retained

## Helm Charts

Helm charts for each service are located in `/gitops/helm-charts/`:

| Chart | Path | Description |
|-------|------|-------------|
| Employee Service | `gitops/helm-charts/employee-service/` | Java Spring Boot service |
| Notification Service | `gitops/helm-charts/notification-service/` | Python service |
| Payroll Service | `gitops/helm-charts/payroll-service/` | .NET service |
| Frontend | `gitops/helm-charts/frontend/` | Angular frontend |

Each chart supports the following common values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `environment` | Target environment name | — |
| `replicaCount` | Number of replicas | `1` |
| `image.tag` | Container image tag | — |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `postgresql.host` | PostgreSQL host | — |
| `postgresql.port` | PostgreSQL port | `5432` |
| `postgresql.database` | Database name | — |

## Bootstrap Procedure

### 1. Install ArgoCD on the Cluster

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Install the ArgoCD CLI

```bash
brew install argocd   # macOS
# or
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

### 3. Retrieve the Initial Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Apply Application Manifests

```bash
argocd login --_GRPC_WEB --plaintext false <argocd-server>

# Apply per environment
kubectl apply -f gitops/argocd/dev/      # Dev
kubectl apply -f gitops/argocd/test/     # Test
kubectl apply -f gitops/argocd/prod/     # Production (requires manual sync)
```

### 5. Verify Sync Status

```bash
argocd app list
argocd app get <app-name>
```

## Repository URL Replacement

To update the repository URL in all Application manifests:

```bash
# Replace the placeholder with your actual repository URL
REPO_URL="https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git"
find gitops/argocd -name "*.yaml" -exec sed -i "s|https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git|$REPO_URL|g" {} \;
```

## ArgoCD Credentials

Repository credentials for ArgoCD must be stored as a Kubernetes Secret in the `argocd` namespace. Never commit credentials or secrets to this repository.

```bash
# Create a GitHub Personal Access Token secret
argocd repo add https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git \
  --username <github-user> \
  --password <token>
```

## Rollback via ArgoCD

To rollback a service to a previous revision:

```bash
# List revision history
argocd app history <app-name>

# Sync to a specific revision
argocd app sync <app-name> --revision <revision>
```

Alternatively, revert the commit in Git and let ArgoCD auto-sync (dev/test) or trigger a manual sync (prod).

## Related Documentation

- Change Management: `/operations/change-management/`
- Deployment Scripts: `/scripts/deployment/`
- SOP (rollback procedure): `/operations/sop/`
- Helm Charts: `/gitops/helm-charts/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu