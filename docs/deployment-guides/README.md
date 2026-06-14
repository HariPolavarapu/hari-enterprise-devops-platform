# Deployment Guide

This document describes the end-to-end deployment process for the Enterprise
DevOps Platform, including CI/CD pipeline stages, GitOps reconciliation,
environment-specific considerations, and rollback procedures.

---

## Overview

The platform uses a GitOps deployment model. Container images are built and
published by CI, and an ArgoCD operator reconciles the desired state into the
Amazon EKS cluster. Direct `kubectl apply` and local `docker compose` are
**not supported** for production deployments.

---

## Deployment Pipeline

### Pipeline Stages

| Stage              | Tool            | Purpose                                            |
|--------------------|-----------------|----------------------------------------------------|
| Validate           | Maven, pytest, dotnet, npm | Build and unit test all services      |
| Quality Gate       | SonarQube       | Enforce code quality, coverage, and reliability    |
| Build Images       | Docker          | Multi-stage builds for each service image          |
| Security Scan      | Trivy           | Block HIGH and CRITICAL vulnerabilities            |
| Publish ECR        | AWS CLI + Docker| Push immutable commit-SHA tagged images to ECR     |
| Publish Artifacts  | Maven + Nexus   | Deploy Java JARs to Sonatype Nexus                 |
| Helm Values Update | CI script       | Update `image.tag` in Helm values via Git commit   |
| ArgoCD Reconcile   | ArgoCD          | Detect Git change and deploy to target namespace   |

### Immutable Image Tags

Every image published to ECR is tagged with the full Git commit SHA:

```
${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/employee-service:<git-sha>
```

Tags are immutable — they cannot be overwritten after push. This ensures every
deployment is traceable to a specific source commit.

---

## Prerequisites

Before deploying to any environment:

1. All pipeline stages (Validate, Quality Gate, Trivy Gate) must pass on `main`
2. Images must be published to ECR
3. Helm values must be updated in Git with the new `image.tag`
4. ArgoCD Application manifests must reference the correct repository and branch

---

## Environment Strategy

| Environment | Namespace   | Reconciliation | Update Trigger        |
|-------------|-------------|----------------|-----------------------|
| Development | `dev`       | Manual or auto | Any commit to `main`  |
| Test        | `test`      | Auto           | Git tag or PR merge   |
| Production  | `prod`      | Auto           | Release tag (`v*`)    |

---

## Step-by-Step Deployment Process

### 1. Merge to Main (Development Deploy)

1. Developer opens a pull request against `main`
2. GitHub Actions CI runs all validation stages
3. PR is reviewed and merged
4. CI publishes images to ECR with the commit SHA tag
5. CI updates the Helm chart values in Git
6. ArgoCD detects the change in the `dev` environment Application
7. ArgoCD reconciles the Helm release in the `dev` namespace
8. Verify the deployment:

```bash
kubectl -n dev get pods
kubectl -n dev get deployments
argocd app get <app-name> --grpc-web
```

### 2. Promote to Test

1. Create a Git tag for the release candidate:

```bash
git tag -a v0.1.0-rc1 -m "Release candidate 1"
git push origin v0.1.0-rc1
```

2. CI detects the tag, runs full validation, and publishes images
3. ArgoCD Application for `test` syncs with the tagged commit
4. Run smoke tests against the test environment:

```bash
curl -f https://test.employee-service.internal/health
curl -f https://test.notification-service.internal/health
curl -f https://test.payroll-service.internal/health
```

### 3. Production Release

1. Create a semver tag following the `vMAJOR.MINOR.PATCH` format:

```bash
git tag -a v1.0.0 -m "Production release 1.0.0"
git push origin v1.0.0
```

2. CI runs the full pipeline against the production ECR repositories
3. Helm values in the production GitOps repository are updated
4. ArgoCD syncs the `prod` Application automatically
5. Monitor rollout:

```bash
kubectl -n prod get pods -w
kubectl -n prod rollout status deployment/employee-service
kubectl -n prod rollout status deployment/notification-service
kubectl -n prod rollout status deployment/payroll-service
kubectl -n prod rollout status deployment/frontend
```

---

## Environment-Specific Notes

### Development

- ArgoCD auto-sync is enabled — any push to `main` triggers reconciliation
- Images use the commit SHA tag; no tag promotion occurs
- Database is shared or per-developer; schema is managed by Flyway migrations
- Log into ArgoCD dashboard:

```bash
argocd login --name dev
argocd app list
```

### Test

- ArgoCD auto-sync is enabled for tagged releases
- ECR images are scanned; Trivy gate must pass before promotion
- Integration tests run against the test namespace
- PostgreSQL test data is seeded from `applications/*/test-data/` if present

### Production

- ArgoCD auto-sync is **disabled**; manual sync approval is required
- Production image tags are immutable; rollback requires a new forward deployment
- RDS deletion protection is enabled — accidental deletion is blocked
- Route 53 records point to the EKS ingress; TLS termination is handled by the
  ingress controller with certificates managed by cert-manager or AWS ACM
- CloudWatch log retention is set to 90 days for auditability

---

## Rollback Procedure

Rollback in a GitOps model is performed by redeploying the previous image tag.
**Do not edit the running state directly** — all changes must be recorded in Git.

### Rollback Steps

1. Identify the previous stable commit SHA or tag:

```bash
git log --oneline -10
git tag -l | sort -V
```

2. Create a rollback commit that restores the previous `image.tag` in the Helm
   values file:

```bash
# Edit the Helm values file
git checkout <previous-stable-commit>
# Restore the previous image tag in values files
git add .
git commit -m "Rollback to <previous-tag>"
git tag <previous-tag>
git push origin <previous-tag>
```

3. ArgoCD detects the change and reconciles automatically (or manually sync):

```bash
argocd app sync <app-name> --revision <previous-tag>
```

4. Verify rollback:

```bash
kubectl -n prod get pods -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}'
```

### Emergency Rollback (CLI)

If Git is unavailable or ArgoCD is unresponsive, use an emergency kubectl-based
rollback to restore stability, then re-commit the change through GitOps:

```bash
# View deployment history
kubectl -n prod rollout history deployment/employee-service

# Roll back to previous revision
kubectl -n prod rollout undo deployment/employee-service

# Verify
kubectl -n prod rollout status deployment/employee-service
```

> **Warning:** Emergency kubectl rollback bypasses GitOps. Re-apply the same
> change through the GitOps pipeline immediately after restoring stability to
> ensure the desired state is recorded in source control.

---

## CI/CD Credentials

Credentials required by the CI/CD pipeline are stored in:

| Credential        | Managed By      | Description                          |
|-------------------|-----------------|--------------------------------------|
| `aws-region`      | Jenkins         | AWS region for ECR and EKS           |
| `aws-account-id`  | Jenkins         | AWS account ID for ECR push          |
| `sonarqube`       | Jenkins         | SonarQube server configuration       |
| `nexus-credentials` | Jenkins       | Nexus username and password          |

These credentials are documented in the root `Jenkinsfile` and must be
configured in Jenkins before running pipelines.

---

## Verify a Successful Deployment

After any deployment, run the following checks:

```bash
# 1. Check all pods are Running
kubectl get pods -n <namespace>

# 2. Check pod logs for errors
kubectl logs -n <namespace> deployment/employee-service --tail=50
kubectl logs -n <namespace> deployment/notification-service --tail=50
kubectl logs -n <namespace> deployment/payroll-service --tail=50

# 3. Check ArgoCD sync status
argocd app get <app-name>

# 4. Hit the health endpoints
curl -sf https://employee-service.<namespace>.internal/health
curl -sf https://notification-service.<namespace>.internal/health
curl -sf https://payroll-service.<namespace>.internal/health

# 5. Check Trivy scan results in CI logs (Trivy must exit 0 for HIGH/CRITICAL)
```

---

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu