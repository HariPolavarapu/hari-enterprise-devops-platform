# Deployment Scripts

Shell scripts for deploying and managing the Hari Enterprise DevOps Platform locally and on Kubernetes. Scripts in this directory support local development, health verification, and Helm-based test deployments. Production reconciliation is owned by ArgoCD.

## Purpose

These scripts provide a safe, documented interface for:
- Setting up a local development environment from scratch.
- Deploying all services locally via Docker Compose.
- Performing health checks against running services.
- Deploying to Kubernetes via Helm.
- Viewing and managing service logs.
- Stopping all local services cleanly.

## Prerequisites

All scripts require the following:

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| `bash` | 4.0+ | Script execution |
| `docker` | 20.10+ | Container runtime |
| `docker-compose` | 1.29+ | Multi-container orchestration |
| `git` | 2.30+ | Repository access |
| `kubectl` | 1.24+ | Kubernetes management (k8s scripts only) |
| `helm` | 3.10+ | Helm chart deployment (k8s scripts only) |

For Kubernetes scripts, `kubectl` must be configured with access to the target cluster.

## Script Inventory

| Script | Purpose | Target |
|--------|---------|--------|
| `setup-dev.sh` | Initialise a new local development environment | Local |
| `deploy-dev.sh` | Build and start all services via Docker Compose | Local |
| `deploy-k8s.sh` | Deploy services to Kubernetes via Helm | Kubernetes |
| `health-check.sh` | Verify all running services are healthy | Local |
| `view-logs.sh` | Stream logs from running services | Local |
| `stop-all.sh` | Stop and optionally remove all containers and volumes | Local |

---

### setup-dev.sh

Initialises a local development environment. Run this once when setting up the project on a new machine.

**Usage:**
```bash
bash scripts/deployment/setup-dev.sh
```

**What it does:**
1. Checks for Docker, Docker Compose, and Git.
2. Generates a secure random password for local PostgreSQL (via `DB_PASSWORD` env var).
3. Creates a `.env` file from the template with the generated password.
4. Creates log directories under `logs/services/`.
5. Pulls required base images (PostgreSQL 16 Alpine, Node 22 Alpine, Eclipse Temurin 17 JRE, .NET SDK 8).

**Output:** A configured `.env` file and Docker images ready for `deploy-dev.sh`.

---

### deploy-dev.sh

Builds all service images and starts all containers via Docker Compose.

**Usage:**
```bash
bash scripts/deployment/deploy-dev.sh
```

**What it does:**
1. Runs `scripts/build/build-all.sh` to build all service images.
2. Starts all services with `docker-compose -f docker-compose.yml up -d`.
3. Waits 10 seconds for services to initialise.
4. Prints access URLs for all services.

**Access URLs:**
| Service | URL |
|---------|-----|
| Frontend | http://localhost:4200 |
| Employee Service | http://localhost:8080 |
| Notification Service | http://localhost:8081 |
| Payroll Service | http://localhost:8082 |

---

### deploy-k8s.sh

Deploys all services to a Kubernetes cluster via Helm. Production deployments should be managed by ArgoCD; this script is intended for test and staging deployments.

**Usage:**
```bash
bash scripts/deployment/deploy-k8s.sh <namespace> [environment]
```

**Arguments:**
- `namespace` — Kubernetes namespace to deploy into (defaults to `enterprise-platform`).
- `environment` — Environment name passed to Helm values (defaults to `dev`).

**Example:**
```bash
# Deploy to enterprise-platform-test namespace, environment=test
bash scripts/deployment/deploy-k8s.sh enterprise-platform-test test
```

**What it does:**
1. Creates the target namespace if it does not exist.
2. Installs/upgrades each Helm chart:
   - `employee-service`
   - `notification-service`
   - `payroll-service`
   - `frontend`
3. Sets `environment.name` Helm value.
4. Waits for resources to become ready with a 5-minute timeout.

**Post-deployment verification:**
```bash
kubectl get pods -n <namespace>
kubectl get services -n <namespace>
```

---

### health-check.sh

Performs health checks against all locally running services via Docker Compose.

**Usage:**
```bash
bash scripts/deployment/health-check.sh
```

**Services checked:**
| Endpoint | Expected Response |
|----------|------------------|
| http://localhost:8080/api/actuator/health | `200` (Employee Service) |
| http://localhost:8081/health | `200` (Notification Service) |
| http://localhost:8082/api/health | `200` (Payroll Service) |
| http://localhost:4200 | `200` (Frontend) |

Also displays:
- Docker Compose container status.
- PostgreSQL readiness via `pg_isready`.

**Exit code:** `0` if all checks pass, non-zero if any check fails.

---

### view-logs.sh

Streams live logs from running Docker Compose services.

**Usage:**
```bash
bash scripts/deployment/view-logs.sh [service]
```

**Arguments:**
- `service` — (Optional) Specific service name. If omitted, streams logs from all services.

**Example:**
```bash
# Stream logs from all services
bash scripts/deployment/view-logs.sh

# Stream logs from employee-service only
bash scripts/deployment/view-logs.sh employee-service
```

---

### stop-all.sh

Stops all Docker Compose services. Optionally removes Docker volumes.

**Usage:**
```bash
bash scripts/deployment/stop-all.sh [-v|--volumes]
```

**Options:**
- Without flags: Stops containers, preserves volumes (data persists).
- `-v` / `--volumes`: Stops containers and removes volumes (destroys all data).

**Example:**
```bash
# Stop services, keep data
bash scripts/deployment/stop-all.sh

# Stop services and destroy volumes
bash scripts/deployment/stop-all.sh --volumes
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_PASSWORD` | PostgreSQL password for local dev | Auto-generated on setup |
| `ENVIRONMENT` | Environment name | `dev` |
| `NAMESPACE` | Kubernetes namespace (k8s script) | `enterprise-platform` |

## Security Notes

- The `.env` file generated by `setup-dev.sh` contains a database password. **Never commit this file to version control.** The `.gitignore` excludes `.env` by default.
- For production deployments, credentials are managed through HashiCorp Vault (`/security/vault/`). Do not use local `.env` files in production.
- The `setup-dev.sh` script generates a secure random password using `openssl rand -base64 32` as a fallback when dedicated secret generation is unavailable.

## Related Documentation

- ArgoCD GitOps: `/gitops/argocd/`
- Helm Charts: `/gitops/helm-charts/`
- CI/CD Pipeline: `/cicd/jenkins/pipelines/servicePipeline.groovy`
- Docker Compose: `docker-compose.yml` (project root)

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu