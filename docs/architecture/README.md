# Architecture

This document describes the architectural components, data flows, and technology
stack of the Enterprise DevOps Platform. It serves as the authoritative reference
for engineers provisioning, maintaining, or extending this infrastructure.

---

## Overview

The platform is a four-service, cloud-native delivery system deployed on Amazon
Web Services. Infrastructure is defined as code with Terraform, container images
are built and scanned in CI, and deployments are reconciled to Amazon EKS through
ArgoCD using a GitOps pattern.

---

## Technology Stack

| Layer              | Component                  | Version / Notes                          |
|--------------------|----------------------------|------------------------------------------|
| Runtime            | Amazon EKS                 | Managed Kubernetes, multi-AZ             |
| Infrastructure     | Terraform                  | IaC for all AWS resources                |
| Container Registry | Amazon ECR                 | Scan-on-push, immutable image tags       |
| CI / Build         | Jenkins                    | Multi-stage pipelines per application    |
| Image Scanning     | Trivy                      | Blocks HIGH/CRITICAL CVEs                |
| Code Quality       | SonarQube                  | Quality gate enforced in CI              |
| GitOps             | ArgoCD                     | Helm-based GitOps reconciliation         |
| Secrets            | HashiCorp Vault            | Scoped, least-privilege secret access    |
| Database           | Amazon RDS PostgreSQL      | Encrypted, automated backups, Multi-AZ   |
| Networking         | Amazon VPC                 | Public/private subnets across 3 AZs      |
| DNS                | Amazon Route 53            | Managed DNS for internal endpoints       |
| Observability      | Prometheus, Grafana, ELK, Tempo, CloudWatch | Metrics, logs, traces, cloud-native |
| Configuration      | Helm 3                     | Templated Kubernetes manifests           |
| Artifact Repo      | Sonatype Nexus             | Hosts internal Java artifacts            |

---

## Platform Services

### Employee Service

- **Framework:** Spring Boot 3
- **Language:** Java 17
- **Runtime:** JVM
- **Purpose:** Core employee record management API
- **Default Port:** `8080`

### Notification Service

- **Framework:** FastAPI
- **Language:** Python 3.12
- **Runtime:** Uvicorn ASGI server
- **Purpose:** Asynchronous notification dispatch (email, webhooks)
- **Default Port:** `8000` (exposed as `8081` in Docker Compose)

### Payroll Service

- **Framework:** ASP.NET Core 8
- **Language:** C# / .NET 8
- **Runtime:** .NET Runtime
- **Purpose:** Payroll processing and reporting API
- **Default Port:** `8080` (exposed as `8082` in Docker Compose)

### Frontend

- **Framework:** Angular 17+
- **Language:** TypeScript
- **Runtime:** NGINX web server
- **Purpose:** Single-page application UI
- **Default Port:** `8080` (exposed as `4200` in Docker Compose)

---

## Infrastructure Components

### VPC Networking

The platform provisions a dedicated VPC with:

- **Public subnets** (3 AZs) – bastion host, NAT gateways
- **Private subnets** (3 AZs) – EKS nodes, RDS instances
- **Availability zones** – `us-east-1a`, `us-east-1b`, `us-east-1c` (default, configurable)

### Amazon EKS

- Managed node groups run in private subnets across three availability zones
- Cluster IAM role and node IAM role follow the principle of least privilege
- Kubernetes RBAC limits pod permissions through security policies

### Amazon RDS PostgreSQL

- **Engine:** PostgreSQL 16
- **Storage:** Encrypted at rest with AWS KMS
- **Backups:** Automated daily snapshots with point-in-time recovery
- **Deletion protection:** Enabled
- **High availability:** Multi-AZ standby

### Amazon ECR

- One repository per service: `employee-service`, `notification-service`,
  `payroll-service`, `frontend`
- **Immutable tags** are enforced — tags cannot be overwritten after push
- **Scan-on-push** inspects every image for HIGH and CRITICAL vulnerabilities

### EC2 Bastion Host

- Deployed in the public subnet
- Accessible via SSH (port 22) only from the operator's IP address
- Used as a jump host for secure access to private infrastructure

### Amazon CloudWatch

- Log groups created for each service and the CI pipeline
- Metrics collected for EKS cluster, RDS, and EC2 resources
- Retention policy applied per log group

---

## Data Flow

### Continuous Integration

```
Developer push
  -> GitHub Actions CI / Jenkins
  -> Parallel build & test (Maven, pytest, dotnet build, Angular build)
  -> SonarQube quality gate (static analysis, coverage, reliability)
  -> Docker image build (multi-stage per service)
  -> Trivy vulnerability scan (HIGH / CRITICAL gate)
  -> AWS ECR push (immutable commit-SHA tag)
  -> Helm chart values updated in Git (image.tag = commit SHA)
  -> ArgoCD detects drift and reconciles EKS deployment
```

### Secrets Flow

```
Vault policy (least-privilege, scoped path)
  -> EKS service account annotation
  -> Kubernetes projected volume or env vars
  -> Application reads secret at runtime
  -> No secret stored in Git, Helm values, or CI environment
```

### Database Initialization

```
RDS PostgreSQL (private subnet)
  -> Employee service JDBC connection (env-driven credentials)
  -> Schema migrations on startup (Spring Boot auto-config)
```

---

## GitOps Structure

```
gitops/
  argocd/          ArgoCD Application manifests (dev, test, prod namespaces)
  helm-charts/     Helm charts for each service
```

- ArgoCD Applications reference Helm charts and point to the Git repository
- The `targetRevision` field tracks the active Git branch
- Image tags in Helm values are updated by CI; ArgoCD reconciles automatically
- Credentials for private Git repositories are stored in ArgoCD secrets, never committed

---

## Observability Stack

| Signal   | Tool        | Endpoint / Port |
|----------|-------------|-----------------|
| Metrics  | Prometheus  | `9090`          |
| Dashboards | Grafana   | `3000`          |
| Logs     | ELK Stack   | `9200` (Elasticsearch), `5601` (Kibana), `5044` (Logstash) |
| Traces   | Tempo       | `4317` (OTLP gRPC) |
| Cloud    | CloudWatch  | AWS-native      |

The observability directory contains configuration for each tool. Prometheus
scrape targets are defined in `prometheus.yml` using service annotations on
Kubernetes Services.

---

## Security Architecture

- **Runtime security:** Workloads run as non-root; Linux capabilities are dropped
- **Pod Security:** Kubernetes restricted profile enforced via Pod Security Standards
- **Network segmentation:** Security groups restrict traffic between tiers
- **Secrets management:** HashiCorp Vault policies enforce scoped, read-only access
- **SBOM generation:** Software Bills of Materials generated for every container image
- **Dependency scanning:** Dependabot monitors all language ecosystems daily
- **Pre-commit hooks:** Gitleaks, detect-secrets, check-added-large-files,
  check-merge-conflict blocks known-bad commits before they reach CI

---

## Local Development Stack

Docker Compose provides a local equivalent of the production environment:

```
postgres          PostgreSQL 16 (port 5432)
employee-service  Spring Boot (port 8080)
notification-service FastAPI (port 8081)
payroll-service   .NET 8 (port 8082)
frontend          Angular / NGINX (port 4200)
```

Credentials are environment-driven via `.env` (copied from `.env.example`).
Direct `kubectl apply` and local `docker compose` are **not supported** for
production deployments — all production changes flow through GitOps.

---

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu