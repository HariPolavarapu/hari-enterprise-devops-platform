# Hari Enterprise DevOps Platform

> **Production-ready, enterprise-grade multi-service delivery platform on AWS.**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![CI](https://github.com/HariPolavarapu/hari-enterprise-devops-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/HariPolavarapu/hari-enterprise-devops-platform/actions)

---

## Overview

The **Hari Enterprise DevOps Platform** is a hardened, enterprise-grade reference implementation of a cloud-native multi-service delivery platform. It demonstrates production-ready patterns for continuous integration, continuous deployment, infrastructure as code, GitOps, secrets management, and full-stack observability on Amazon Web Services.

This platform serves as a blueprint for organizations building scalable, secure, and observable internal platforms. Every component—from application source code to infrastructure provisioning—follows enterprise security standards, least-privilege access principles, and automated governance.

---

## Table of Contents

- [Architecture](#architecture)
  - [System Architecture](#system-architecture)
  - [Component Architecture](#component-architecture)
  - [Data Flow](#data-flow)
  - [Network Topology](#network-topology)
  - [Security Architecture](#security-architecture)
- [Delivery Pipeline](#delivery-pipeline)
- [Repository Structure](#repository-structure)
- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Local Development](#local-development)
- [AWS Provisioning](#aws-provisioning)
- [GitOps Deployment](#gitops-deployment)
- [Security Controls](#security-controls)
- [Observability](#observability)
- [Operations](#operations)
- [Contributing](#contributing)
- [Security Reporting](#security-reporting)
- [License](#license)
- [Maintainer](#maintainer)

---

## Architecture

### System Architecture

The platform follows a modern microservices architecture deployed on Amazon Elastic Kubernetes Service (EKS). All infrastructure is provisioned through Terraform, application delivery is managed via GitOps with ArgoCD, and secrets are centralized in HashiCorp Vault.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Client Layer                                    │
│  ┌─────────────┐                                                            │
│  │  Angular SPA │  ←── Served by NGINX (frontend-angular)                   │
│  └──────┬──────┘                                                            │
└─────────┼────────────────────────────────────────────────────────────────────┘
          │ HTTPS
┌─────────┼────────────────────────────────────────────────────────────────────┐
│         ▼                         AWS Cloud                                  │
│  ┌─────────────┐    Route 53    ┌──────────────┐                            │
│  │  CloudFront │ ←─────────────→│  ALB (EKS)   │                            │
│  │   (CDN)     │                └──────┬───────┘                            │
│  └─────────────┘                       │                                     │
│                                        ▼                                     │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                    Amazon EKS Cluster                               │     │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │     │
│  │  │ Employee Service│  │ Notification Svc│  │  Payroll Service│    │     │
│  │  │  (Spring Boot)  │  │   (FastAPI)     │  │  (ASP.NET Core) │    │     │
│  │  │   Port: 8080    │  │   Port: 8000    │  │   Port: 8080    │    │     │
│  │  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘    │     │
│  │           │                    │                    │              │     │
│  │           └────────────────────┼────────────────────┘              │     │
│  │                                ▼                                   │     │
│  │                    ┌─────────────────────┐                         │     │
│  │                    │   RDS PostgreSQL    │                         │     │
│  │                    │   (Encrypted)       │                         │     │
│  │                    └─────────────────────┘                         │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                         AWS ECR Registry                            │     │
│  │     Immutable image tags with scan-on-push enabled                  │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                         HashiCorp Vault                             │     │
│  │     Scoped secrets access via Kubernetes auth backend               │     │
│  └────────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         CI/CD & GitOps Layer                                 │
│                                                                             │
│  ┌──────────────┐    ┌───────────┐    ┌──────────┐    ┌──────────────┐    │
│  │ GitHub Actions│───→│  ECR Push │───→│ Helm     │───→│   ArgoCD     │    │
│  │   or Jenkins  │    │           │    │ Values   │    │  (GitOps)    │    │
│  └──────────────┘    └───────────┘    └──────────┘    └──────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                      Observability Stack                                     │
│                                                                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────────────┐    │
│  │ Prometheus │  │  Grafana   │  │   Tempo    │  │ ELK Stack          │    │
│  │  (Metrics) │  │(Dashboards)│  │  (Traces)  │  │ (Logs)             │    │
│  └────────────┘  └────────────┘  └────────────┘  └────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Component Architecture

The application tier consists of four independently deployable microservices, each using a technology stack aligned with its domain requirements:

| Service | Language / Framework | Runtime | Database | Port | Health |
|---------|---------------------|---------|----------|------|--------|
| **Employee Service** | Java 17 / Spring Boot 3.3 | JVM | PostgreSQL / H2 (test) | 8080 | `/api/actuator/health` |
| **Notification Service** | Python 3.12 / FastAPI | Uvicorn | PostgreSQL | 8000 | `/health` |
| **Payroll Service** | C# / ASP.NET Core 8 | .NET Runtime | PostgreSQL | 8080 | `/health` |
| **Frontend** | TypeScript / Angular 17+ | NGINX | — | 8080 | `/` |

Each service exposes:
- **REST API** endpoints for business operations
- **Health checks** for Kubernetes liveness and readiness probes
- **Prometheus metrics** via Micrometer (Java) or native instrumentation
- **Structured logging** in JSON format for centralized log aggregation

### Data Flow

#### Request Flow (User → Application)

1. End-user accesses the Angular SPA via HTTPS through CloudFront → ALB
2. Angular SPA calls backend APIs through the ALB ingress controller
3. API Gateway / Ingress routes requests to the appropriate Kubernetes Service
4. Service containers process requests and query the shared RDS PostgreSQL instance
5. Responses flow back through the same path with correlation IDs for traceability

#### CI/CD Flow (Commit → Production)

1. Developer pushes code to a feature branch
2. GitHub Actions triggers the CI workflow (or Jenkins pipeline)
3. Parallel validation: Maven/JUnit, pytest, .NET build, Angular build
4. SonarQube quality gate evaluates code coverage and maintainability
5. Docker images are built per service with immutable commit-SHA tags
6. Trivy vulnerability scanner blocks HIGH/CRITICAL findings
7. Clean images are published to AWS ECR with immutable tags
8. Helm values are updated in Git to reference the new image tag
9. ArgoCD detects drift and reconciles the target cluster state
10. Kubernetes performs a zero-downtime rolling update

### Network Topology

Infrastructure is provisioned across three availability zones with strict network segmentation:

| Layer | CIDR Range | Purpose |
|-------|------------|---------|
| **VPC** | `10.0.0.0/16` | Primary network boundary |
| **Public Subnets** | `10.0.1.0/24`, `10.0.2.0/24` | ALB, NAT Gateways, Bastion hosts |
| **Private Subnets** | `10.0.11.0/24`, `10.0.12.0/24` | EKS nodes, application workloads |
| **Database Subnets** | `10.0.21.0/24`, `10.0.22.0/24` | RDS PostgreSQL (isolated) |

**Security Group Rules:**
- ALB: Ingress 443 from CloudFront only
- EKS Nodes: Ingress 80/443 from ALB; Egress to RDS port 5432
- RDS: Ingress 5432 from EKS nodes only; no public access
- Bastion: Ingress 22 from authorized CIDR only (SSM preferred)

### Security Architecture

Security is implemented in layers following the Defense-in-Depth principle:

| Layer | Control | Implementation |
|-------|---------|----------------|
| **Source Control** | Secret scanning | Gitleaks pre-commit hook, detect-private-key |
| **Build** | SAST / Quality | SonarQube quality gate |
| **Artifacts** | Vulnerability scanning | Trivy HIGH/CRITICAL blocker |
| **Registry** | Image immutability | ECR immutable tags + scan-on-push |
| **Cluster** | Pod hardening | Non-root containers, dropped capabilities, restricted profile |
| **Network** | Segmentation | Private subnets, security groups, no public DB access |
| **Secrets** | Centralized vault | HashiCorp Vault with scoped Kubernetes auth |
| **Data** | Encryption | RDS encryption at rest, TLS in transit |
| **Access** | Least privilege | IAM roles, Kubernetes RBAC, Vault ACL policies |

---

## Delivery Pipeline

```text
Developer Push
    │
    ├─── GitHub Actions CI ─────────────────────────────────┐
    │                                                         │
    ▼                                                         │
┌─────────────────┐    ┌─────────────────┐    ┌────────────┐ │
│  Build & Test   │───→│  Quality Gate   │───→│  SonarQube │ │
│  (Parallel)     │    │                 │    │  Scan      │ │
└─────────────────┘    └─────────────────┘    └────────────┘ │
    │                                          Pass/Fail     │
    ▼ Fail ─────────────── Abort                             │
    ▼ Pass                                                   │
┌─────────────────┐    ┌─────────────────┐    ┌────────────┐ │
│  Docker Build   │───→│  Trivy Scan     │───→│  ECR Push  │ │
│  (Multi-stage)  │    │  (Block H/C)    │    │  Immutable │ │
└─────────────────┘    └─────────────────┘    └────────────┘ │
    │                                                         │
    ▼                                                         │
┌─────────────────┐    ┌─────────────────┐    ┌────────────┐ │
│  Helm Values    │───→│  ArgoCD Sync    │───→│  Rolling   │ │
│  Update in Git  │    │  (Drift Detect) │    │  Update    │ │
└─────────────────┘    └─────────────────┘    └────────────┘ │
                                                              │
Jenkins Pipeline (Alternative) ───────────────────────────────┘
```

---

## Repository Structure

```
hari-enterprise-devops-platform/
│
├── applications/                 # Microservice source code
│   ├── employee-java-service/    # Spring Boot 3 employee API
│   ├── notification-python-service/  # FastAPI notification API
│   ├── payroll-dotnet-service/   # ASP.NET Core payroll API
│   └── frontend-angular/         # Angular SPA with NGINX
│
├── cicd/                         # CI/CD configuration
│   ├── jenkins/pipelines/        # Declarative pipeline definitions
│   ├── nexus/                    # Maven artifact repository settings
│   └── trivy/                    # Container vulnerability scan policies
│
├── docs/                         # Technical documentation
│   ├── architecture/             # Architecture diagrams and decisions
│   ├── deployment-guides/        # Environment-specific deployment guides
│   ├── setup-guides/             # Local and cloud platform setup
│   └── troubleshooting/          # Diagnostic runbooks
│
├── gitops/                       # GitOps configuration
│   ├── argocd/                   # ArgoCD Application manifests
│   └── helm-charts/              # Helm charts per service
│
├── infrastructure/               # Infrastructure as Code
│   ├── terraform/                # AWS resource provisioning
│   │   ├── modules/              # Reusable Terraform modules
│   │   │   ├── vpc/              # VPC, subnets, routing
│   │   │   ├── eks/              # Kubernetes cluster
│   │   │   ├── rds/              # PostgreSQL database
│   │   │   ├── ecr/              # Container registries
│   │   │   ├── ec2/              # Bastion / DevOps host
│   │   │   ├── iam/              # Identity and access management
│   │   │   ├── route53/          # DNS configuration
│   │   │   └── cloudwatch/       # Logging and monitoring
│   │   └── main.tf               # Root module composition
│   └── ansible/                  # Host configuration playbooks
│
├── observability/                # Observability stack
│   ├── prometheus/               # Metrics collection
│   ├── grafana/                  # Dashboards and visualization
│   ├── elk/                      # Centralized logging
│   ├── tempo/                    # Distributed tracing
│   └── cloudwatch/               # AWS-native monitoring
│
├── operations/                   # Operational procedures
│   ├── incident-management/      # Incident response workflow
│   ├── change-management/        # Change approval process
│   ├── rca/                      # Root cause analysis templates
│   └── sop/                      # Standard operating procedures
│
├── scripts/                      # Automation scripts
│   ├── deployment/               # Deployment and setup scripts
│   ├── database/                 # Database migration scripts
│   └── validation/               # Repository health checks
│
└── security/                     # Security configuration
    ├── vault/                    # HashiCorp Vault policies
    │   ├── policies/             # Path-based ACL policies
    │   └── config/               # Server configuration
    ├── rbac/                     # Kubernetes RBAC manifests
    └── policies/                 # Organizational security policies
```

---

## Technology Stack

### Application Layer

| Technology | Version | Purpose |
|------------|---------|---------|
| Java | 17 LTS | Employee Service runtime |
| Spring Boot | 3.3 | Employee Service framework |
| Maven | 3.9 | Java build and dependency management |
| Python | 3.12 | Notification Service runtime |
| FastAPI | Latest | Notification Service framework |
| .NET | 8.0 LTS | Payroll Service runtime |
| ASP.NET Core | 8.0 | Payroll Service framework |
| Angular | 17+ | Frontend framework |
| TypeScript | 5.x | Frontend language |
| NGINX | Alpine | Static file server and reverse proxy |

### Infrastructure Layer

| Technology | Version | Purpose |
|------------|---------|---------|
| Terraform | 1.5+ | Infrastructure provisioning |
| AWS Provider | 5.x | AWS resource management |
| Ansible | 2.15+ | Host configuration |
| Amazon EKS | 1.29+ | Kubernetes orchestration |
| Amazon RDS | PostgreSQL 16 | Relational database |
| Amazon ECR | — | Container image registry |
| Helm | 3.14+ | Kubernetes package management |

### CI/CD Layer

| Technology | Version | Purpose |
|------------|---------|---------|
| GitHub Actions | — | Primary CI/CD platform |
| Jenkins | 2.4+ | Alternative CI/CD platform |
| SonarQube | 10.x | Code quality and SAST |
| Trivy | 0.55+ | Container vulnerability scanning |
| Nexus | 3.x | Artifact repository |

### Observability Layer

| Technology | Version | Purpose |
|------------|---------|---------|
| Prometheus | 2.50+ | Metrics collection |
| Grafana | 10.x | Metrics visualization |
| Elasticsearch | 8.x | Log storage and search |
| Logstash | 8.x | Log ingestion and processing |
| Kibana | 8.x | Log visualization |
| Tempo | 2.4+ | Distributed trace storage |
| Jaeger / OTLP | — | Trace ingestion protocol |

### Security Layer

| Technology | Version | Purpose |
|------------|---------|---------|
| HashiCorp Vault | 1.16+ | Secrets management |
| Kubernetes RBAC | — | In-cluster access control |
| Pod Security Standards | Restricted | Pod hardening baseline |
| Pre-commit | 4.x | Local commit validation |
| Gitleaks | 8.21+ | Secret leak detection |

---

## Getting Started

### Prerequisites

**Required for local development:**
- Git 2.40+
- Docker Engine 24+
- Docker Compose v2+
- Make

**Required for full platform deployment:**
- Terraform 1.5+
- AWS CLI 2.x (configured with credentials)
- kubectl 1.29+
- Helm 3.14+
- Ansible 2.15+

**Required for application development:**
- Java 17 JDK + Maven 3.9+ (Employee Service)
- Python 3.12 + pip (Notification Service)
- .NET 8 SDK (Payroll Service)
- Node.js 20+ + npm (Frontend)

### Quick Start

Start the full platform locally in under 5 minutes:

```bash
# 1. Clone the repository
git clone https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git
cd hari-enterprise-devops-platform

# 2. Create local environment
cp .env.example .env

# 3. Start all services
docker compose up --build -d

# 4. Verify health
docker compose ps

# 5. Access the application
open http://localhost:4200
```

### Local Development

The project includes a unified Makefile for common operations:

| Command | Description |
|---------|-------------|
| `make validate` | Run Terraform, Helm, and application validation |
| `make test` | Execute all service test suites |
| `make build` | Build all container images |
| `make up` | Start the local Docker Compose stack |
| `make down` | Stop the local stack |
| `make logs` | Tail container logs |
| `make terraform-validate` | Validate Terraform configuration |
| `make helm-lint` | Lint all Helm charts |

For service-specific development, see the README in each `applications/` subdirectory.

---

## AWS Provisioning

> **⚠️ Security Warning:** Never commit secrets to version control. All sensitive values must be provided through environment variables, HashiCorp Vault, or your organization's secrets manager.

### Step 1: Configure Terraform Backend

```bash
cd infrastructure/terraform

# Copy and edit backend configuration
cp backend.hcl.example backend.hcl
# Edit: bucket, key, region, dynamodb_table
cp terraform.tfvars.example terraform.tfvars
# Edit: aws_region, project_name, my_ip, ami_id, public_key_path, database_password
```

### Step 2: Provision Infrastructure

```bash
terraform init -backend-config=backend.hcl
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 3: Configure and Run Ansible

```bash
cd infrastructure/ansible
# Edit inventories/hosts.ini with provisioned host IPs
ansible-playbook -i inventories/hosts.ini site.yml
```

### Step 4: Configure Jenkins (Optional)

Configure the following credential IDs in Jenkins:
- `aws-region`
- `aws-account-id`
- `nexus-credentials`
- `sonarqube`

---

## GitOps Deployment

All Kubernetes workloads are defined as Helm charts in `gitops/helm-charts/`. ArgoCD Applications in `gitops/argocd/` reference these charts and are organized by environment namespace.

### Environment Namespaces

| Environment | Namespace | Purpose |
|-------------|-----------|---------|
| Development | `enterprise-platform-dev` | Feature branch integration |
| Test | `enterprise-platform-test` | QA and integration testing |
| Production | `enterprise-platform-prod` | Live traffic |

### Deployment Flow

1. CI publishes a new image to ECR with a commit-SHA tag
2. Image tag is updated in the target environment's Helm values
3. ArgoCD detects the Git drift (auto-sync or manual sync)
4. ArgoCD renders the Helm chart and applies changes to the cluster
5. Kubernetes performs a rolling update with zero downtime
6. ArgoCD reports sync status and health of all resources

**Critical:** Never hardcode credentials into Helm values or ArgoCD manifests. Use Vault agent injection, external secrets operators, or ArgoCD secret management.

---

## Security Controls

This platform implements defense-in-depth security across every layer:

| Control Category | Implementation | Verification |
|------------------|----------------|--------------|
| **Secret Prevention** | Gitleaks + detect-private-key pre-commit hooks | `pre-commit run --all-files` |
| **Code Quality** | SonarQube quality gate with coverage thresholds | CI pipeline stage |
| **Vulnerability Scanning** | Trivy blocks HIGH/CRITICAL CVEs | CI pipeline stage |
| **Image Security** | ECR scan-on-push + immutable tags | AWS ECR console |
| **Runtime Hardening** | Non-root containers, dropped capabilities, read-only root filesystem | Pod Security Standards |
| **Network Security** | Private subnets, security groups, no public database access | Terraform plan review |
| **Secrets Management** | HashiCorp Vault with Kubernetes auth backend | Vault audit logs |
| **Data Protection** | RDS encryption at rest, TLS 1.2+ in transit | AWS KMS + cert validation |
| **Access Control** | IAM roles, Kubernetes RBAC, Vault ACL policies | Quarterly access review |
| **Dependency Security** | Dependabot daily scanning across all ecosystems | GitHub Security tab |
| **Supply Chain** | SBOM generation per container image | CI artifact upload |
| **Audit Logging** | CloudTrail, EKS audit logs, Vault audit logs | Centralized ELK ingestion |

---

## Observability

The platform implements the three pillars of observability:

### Metrics (Prometheus + Grafana)
- Application metrics via Micrometer (Java) and native instrumentation (Python, .NET)
- Infrastructure metrics via node-exporter and kube-state-metrics
- Alerting rules for error rate, latency, and saturation thresholds

### Logs (ELK Stack)
- Structured JSON logging from all services
- Logstash ingestion pipeline with parsing and enrichment
- Elasticsearch hot-warm architecture for cost-effective retention
- Kibana dashboards for error analysis and audit trails

### Traces (Tempo)
- OpenTelemetry instrumentation across all services
- Trace correlation via W3C Trace Context headers
- Grafana Tempo for trace storage and retrieval
- Jaeger UI for trace visualization

### CloudWatch Integration
- AWS-native metrics and log groups for infrastructure
- CloudWatch Container Insights for EKS cluster metrics
- Cross-region log aggregation to centralized security account

---

## Operations

Production operations are governed by documented procedures:

| Procedure | Location | Description |
|-----------|----------|-------------|
| **Incident Management** | `operations/incident-management/` | Classification, commander assignment, stabilization, communication, post-incident review |
| **Change Management** | `operations/change-management/` | PR requirements, plan review, rollback targets, approval matrix |
| **Root Cause Analysis** | `operations/rca/` | Impact recording, timeline reconstruction, contributing factors, corrective actions |
| **Standard Operating Procedures** | `operations/sop/` | Deployment verification, rollback execution, backup validation, access review, certificate rotation, disaster recovery |

All procedures require explicit environment targeting and approval from designated CODEOWNERS.

---

## Contributing

We welcome contributions that improve the platform's reliability, security, and usability.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of conduct
- Pull request process and DCO sign-off requirements
- Language-specific style guides (Java, Python, C#, TypeScript, Terraform, Ansible, Shell)
- Security requirements for contributors

All contributions are licensed under the Apache License 2.0.

---

## Security Reporting

If you discover a security vulnerability, please follow our coordinated disclosure process:

1. **Do not open a public issue.**
2. Report via [GitHub Security Advisories](https://github.com/HariPolavarapu/hari-enterprise-devops-platform/security/advisories) or email `security@your-org.example` (PGP key available upon request).
3. We will acknowledge within 5 business days and provide a timeline for remediation.
4. Public disclosure follows our 90-day coordinated disclosure policy.

Full details are available in [SECURITY.md](SECURITY.md).

---

## License

This project is licensed under the Apache License, Version 2.0.

See [LICENSE](LICENSE) for the full license text.

---

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: [https://github.com/HariPolavarapu](https://github.com/HariPolavarapu)
- LinkedIn: [https://linkedin.com/in/hari-krishna-polavarapu](https://linkedin.com/in/hari-krishna-polavarapu)
