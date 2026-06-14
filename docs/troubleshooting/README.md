# Troubleshooting Guide

This document describes common issues encountered in the Enterprise DevOps
Platform, their diagnostic steps, and resolution procedures. Issues are
organized by the layer at which they occur.

---

## Overview

When diagnosing a failure, follow this order:

1. **Identify the layer** — CI pipeline, container image, Kubernetes deployment,
   or infrastructure provisioning
2. **Isolate the component** — Narrow to the specific service or stage that failed
3. **Check logs first** — Application logs, CI logs, pod events, and Terraform
   plan output contain the most actionable information
4. **Reproduce locally** — Attempt to reproduce the issue with `docker compose`
   before modifying cloud infrastructure

---

## CI/CD Pipeline Failures

### CI Build Failure

**Symptoms:** Pipeline stage fails with a non-zero exit code; build artifacts
are not published to ECR.

**Diagnosis:**

```bash
# Check the Jenkins or GitHub Actions log for the failed stage
# Look for the specific test failure or compilation error

# For Maven failures:
cd applications/employee-java-service
mvn -B clean verify
# Review target/surefire-reports/ for failing test details

# For Python failures:
cd applications/notification-python-service
. .venv/bin/activate
pytest --junitxml=test-results.xml -v

# For .NET failures:
cd applications/payroll-dotnet-service
dotnet build --configuration Release
dotnet test

# For Angular failures:
cd applications/frontend-angular
npm install
npm run build
```

**Resolution:**
1. Fix the failing test or compilation error in the source code
2. Push the fix to the branch — CI will rerun automatically
3. Do not bypass failing tests to merge a build

---

### SonarQube Quality Gate Failure

**Symptoms:** Pipeline fails at the "Quality Gate" stage; the SonarQube dashboard
shows a red quality gate status.

**Diagnosis:**

```bash
# Check the quality gate conditions in SonarQube:
# Navigate to SonarQube dashboard -> project -> quality gate
# Identify which metric failed: coverage, duplication, maintainability, reliability, security

# Common thresholds:
# - Coverage < 80%
# - Duplicated lines > 3%
# - Maintainability rating below A
# - Reliability rating below A
# - Security rating below A
```

**Resolution:**

1. Review the specific issue in SonarQube under "Issues"
2. Address the root cause (add tests, fix duplication, resolve code smell)
3. Do not lower the quality gate threshold as a workaround

---

### Trivy Vulnerability Gate Failure

**Symptoms:** Pipeline fails at the "Trivy Gate" stage with HIGH or CRITICAL
vulnerabilities detected.

**Diagnosis:**

```bash
# Run Trivy locally against the built image:
docker build -t my-image:local applications/employee-java-service
trivy image --severity HIGH,CRITICAL --ignore-unfixed my-image:local

# Check the specific CVE IDs and package versions:
trivy image --severity HIGH,CRITICAL my-image:local --format json
```

**Resolution:**

1. Identify the affected package and the available upgrade version
2. Update the dependency version in the application's requirements or build file
3. Rebuild and resubmit — the Trivy gate must pass before publication
4. If no fix is available, assess whether the vulnerability is exploitable in
   the runtime environment and document the exception in the security record

---

### Image Pull Failure (EKS)

**Symptoms:** Pods in EKS are in `ImagePullBackOff` or `ErrImagePull` state.

**Diagnosis:**

```bash
# Check the pod status and events
kubectl describe pod <pod-name> -n <namespace>

# Verify the ECR repository exists
aws ecr describe-repositories --region us-east-1

# Verify the image tag exists
aws ecr list-images --repository-name employee-service --region us-east-1

# Check the EKS node IAM role has ECR read permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:role/eks-node-role \
  --action-names ecr:GetAuthorizationToken,ecr:BatchCheckLayerAvailability,ecr:GetDownloadUrlForLayer
```

**Resolution:**

1. Confirm the image was published successfully in CI (check ECR in the AWS Console)
2. Verify the `image.tag` in Helm values matches a valid ECR tag
3. Confirm the EKS node role has `AmazonEC2ContainerRegistryReadOnly` policy attached
4. If using private networking, ensure the EKS cluster has VPC interface endpoints
   for ECR

---

## Kubernetes Deployment Failures

### ArgoCD Out of Sync

**Symptoms:** ArgoCD Application shows `OutOfSync` status; no new deployment
is detected in the target namespace.

**Diagnosis:**

```bash
# Check ArgoCD application status
argocd app get <app-name>
argocd app history <app-name>

# Check for sync errors
argocd app logs <app-name>

# Compare live state vs desired state
argocd app diff <app-name>

# Render the Helm chart locally to inspect the values
helm template gitops/helm-charts/employee-service \
  --set image.tag=abc1234 \
  --namespace dev
```

**Resolution:**

1. Verify the Git commit with the Helm values update was pushed successfully
2. Check that ArgoCD can reach the Git repository (network, credentials)
3. If the targetRevision points to a branch, verify the branch exists
4. Manually sync the application:

```bash
argocd app sync <app-name>
```

---

### Pod Readiness Failure

**Symptoms:** Pods are running but are not `Ready`; service endpoints are
not updated.

**Diagnosis:**

```bash
# Check pod status
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>

# Check readiness probe failures
kubectl logs <pod-name> -n <namespace> --tail=50

# Check if the health endpoint is responding
kubectl exec -it <pod-name> -n <namespace> -- curl -sf localhost:8080/actuator/health

# Check secret references are correct
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[*].env[*].name}'
```

**Resolution:**

1. Verify the health endpoint returns HTTP 200 with a valid JSON body
2. Confirm all required Kubernetes Secrets exist in the namespace and are
   correctly referenced in the Pod spec
3. Check that environment variable names match what the application expects
4. If the database connection fails, verify the RDS security group allows the
   EKS node CIDR on port 5432

---

### ArgoCD Application Not Found

**Symptoms:** `argocd app get` returns "not found" or ArgoCD dashboard does
not show any Applications.

**Diagnosis:**

```bash
# Verify ArgoCD is installed and running
kubectl get pods -n argocd

# Check if Application manifests are applied
kubectl get applications -n argocd
kubectl get application <app-name> -n argocd -o yaml

# Review ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server --tail=50
```

**Resolution:**

1. Apply the ArgoCD Application manifests:

```bash
kubectl apply -f gitops/argocd/applications.yml
```

2. Verify the repository is registered in ArgoCD:

```bash
argocd repo list
```

3. If using a fork, update the repository URL in the Application manifest to
   point to your fork and update `targetRevision` as needed

---

## Infrastructure Failures

### Terraform Validate Failure

**Symptoms:** `terraform validate` reports a syntax error or provider
configuration issue.

**Diagnosis:**

```bash
cd infrastructure/terraform

# Re-run with verbose output
terraform validate -json

# Check for common issues:
# - Missing required variables in terraform.tfvars
# - Incorrect provider version constraints in versions.tf
# - Syntax errors in .tf files

# Format check
terraform fmt -check -recursive
```

**Resolution:**

1. Fix syntax errors identified by `terraform fmt`
2. Ensure all required variables are defined in `terraform.tfvars`
3. Run `terraform init` again to fetch provider plugins
4. Review the error message for the specific failing resource or variable

---

### Terraform Plan Shows Unexpected Changes

**Symptoms:** `terraform plan` shows resource replacement or deletion that was
not intended.

**Diagnosis:**

```bash
# Review the full plan output before applying
terraform plan -out=devops.plan

# Check if the state file is stale (infrastructure was modified manually)
aws s3api head-object --bucket your-terraform-state-bucket --key devops-platform/terraform.tfstate

# Compare the current state with the actual AWS resources
terraform plan -refresh-only
```

**Resolution:**

1. **Never run `terraform apply` with unexpected destructive changes**
2. If state drift is the cause, assess whether to import the existing resource
   or accept the planned correction
3. If the change is unintended, investigate what modified the infrastructure
   outside of Terraform before proceeding

---

### Terraform Apply Failure

**Symptoms:** `terraform apply` fails partway through, leaving resources in a
partial state.

**Diagnosis:**

```bash
# Check the error message from the failed apply
# Identify which resource caused the failure

# Common causes:
# - IAM role conflict (resource already exists)
# - VPC CIDR conflict (overlapping CIDR blocks)
# - Insufficient AWS permissions
# - Service quota exceeded

# Verify current state
terraform show
```

**Resolution:**

1. Run `terraform apply` again — Terraform is idempotent and will resume
   from the point of failure
2. If the failure is persistent, run `terraform plan` to identify the exact
   conflict before retrying
3. Do not manually create AWS resources that Terraform is trying to create —
   this causes conflicts

---

## Local Development Issues

### Docker Compose Container Fails to Start

**Symptoms:** Container exits immediately after start; `docker compose ps` shows
the service as `Exited`.

**Diagnosis:**

```bash
# Check the container logs
docker compose logs <service-name>

# Common causes:
# - Missing environment variables (DB_PASSWORD not set)
# - Port already in use
# - Database not ready (dependency not healthy)
# - Missing volume mounts
```

**Resolution:**

1. Ensure `DB_PASSWORD` is set in `.env` before running `make up`
2. Stop services using conflicting ports:

```bash
lsof -i :5432 -i :8080 -i :8081 -i :8082 -i :4200
```

3. Wait for database to be healthy before dependent services start:

```bash
docker compose up -d postgres
docker compose wait postgres
docker compose up -d
```

---

### PostgreSQL Connection Refused

**Symptoms:** Employee service logs show `Connection refused` to PostgreSQL on
startup.

**Diagnosis:**

```bash
# Check if PostgreSQL is running
docker compose ps postgres

# Check PostgreSQL logs
docker compose logs postgres

# Test connection from the employee-service container
docker compose exec employee-service sh -c 'nc -zv postgres 5432'

# Verify DB credentials match between .env and employee-service environment
grep -E 'DB_USER|DB_PASSWORD' .env
```

**Resolution:**

1. Ensure the `postgres` container is healthy before starting dependent services
2. Verify `DB_USER` and `DB_PASSWORD` in `.env` match the values the employee
   service is configured to use (via environment variables)
3. Restart the stack cleanly:

```bash
make down
make up
```

---

## Verification Commands Quick Reference

```bash
# 1. ArgoCD app sync status
argocd app get <app-name>

# 2. Pod status in namespace
kubectl get pods -n <namespace>

# 3. Pod events (last failure reason)
kubectl describe pod <pod-name> -n <namespace> | grep -A5 Events

# 4. Application logs
kubectl logs -n <namespace> deployment/<deployment-name> --tail=100

# 5. ArgoCD diff vs live state
argocd app diff <app-name>

# 6. Helm template rendering
helm template gitops/helm-charts/<chart> --namespace <namespace>

# 7. Trivy scan
trivy image --severity HIGH,CRITICAL <image-url>

# 8. Terraform validate
make terraform-validate

# 9. Docker Compose health
docker compose ps
docker compose logs --tail=20 <service>
```

---

## Getting Help

If the issue persists after following these steps:

1. Collect relevant logs and command outputs
2. Check the [GitHub Issues](https://github.com/HariPolavarapu/hari-enterprise-devops-platform/issues)
3. Review [CONTRIBUTING.md](../../CONTRIBUTING.md) for the PR and issue process

---

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu