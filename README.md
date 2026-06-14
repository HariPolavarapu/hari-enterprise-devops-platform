# Enterprise DevOps Platform

A hardened, enterprise-grade reference implementation of a multi-service delivery
platform on AWS. This repository demonstrates production-ready patterns for
build automation, security gates, container delivery, infrastructure
provisioning, GitOps deployment, secrets management, and observability.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Delivery Flow](#delivery-flow)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [AWS Provisioning](#aws-provisioning)
- [GitOps Deployment](#gitops-deployment)
- [Security Controls](#security-controls)
- [Observability](#observability)
- [Operations](#operations)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)
- [Maintainer](#maintainer)

## Architecture Overview

The platform consists of four microservices deployed on Amazon EKS,
provisioned through Terraform, and reconciled via ArgoCD:

| Service | Technology | Runtime |
|---------|------------|---------|
| Employee Service | Spring Boot 3 / Java 17 | JVM |
| Notification Service | FastAPI / Python 3.12 | Uvicorn |
| Payroll Service | ASP.NET Core 8 | .NET Runtime |
| Frontend | Angular 17+ | NGINX |

Infrastructure includes VPC networking, EKS cluster, ECR registries, RDS
PostgreSQL, EC2 bastion hosts, Route 53 DNS, and CloudWatch log groups.

## Delivery Flow

```text
Git push
  -> GitHub Actions CI / Jenkins
  -> Maven / JUnit, pytest, .NET build, Angular build
  -> SonarQube quality gate
  -> Docker image build
  -> Trivy vulnerability gate (HIGH / CRITICAL)
  -> AWS ECR push (immutable tags)
  -> Helm values update in Git
  -> ArgoCD reconciliation
  -> AWS EKS deployment
```

## Repository Structure

```text
applications/          Application source, tests, Dockerfiles, and pipelines
  employee-java-service/      Spring Boot employee API
  notification-python-service/ FastAPI notification API
  payroll-dotnet-service/     ASP.NET Core payroll API
  frontend-angular/           Angular SPA with NGINX delivery

cicd/                  Jenkins pipelines, Nexus settings, Trivy config
docs/                  Architecture diagrams, deployment guides, setup guides
gitops/                Helm charts and ArgoCD Application manifests
infrastructure/        Terraform modules and Ansible playbooks
observability/         Prometheus, Grafana, ELK, Tempo, CloudWatch config
operations/            Incident, change, RCA, and SOP documentation
scripts/               Build, deployment, database, and validation automation
security/              Vault policies, Kubernetes RBAC, Pod Security configs
```

## Prerequisites

- Git
- Docker Engine 24+
- Docker Compose v2+
- Make

For full platform deployment you will also need:
- Terraform 1.5+
- AWS CLI
- kubectl
- Helm 3+
- Ansible 2.15+
- Java 17, Maven 3.9+
- Python 3.12
- .NET 8 SDK
- Node.js 20+

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git
cd hari-enterprise-devops-platform

# 2. Create local environment file
cp .env.example .env

# 3. Start the local stack
docker compose up --build

# 4. Access the frontend
open http://localhost:4200
```

## Local Development

Run repository checks:

```bash
# Validate all components
make validate

# Run application tests
make test

# Build local container images
make build

# Start / stop the stack
make up
make down

# View logs
make logs
```

Individual services can also be started independently. See the README in each
`applications/` subdirectory for service-specific instructions.

## AWS Provisioning

> **Warning:** Never commit secrets. All sensitive values must be provided
> through environment variables or your organization's secrets manager.

```bash
cd infrastructure/terraform

# Copy example files to untracked local configuration
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl

# Edit terraform.tfvars and backend.hcl with your environment values
# (my_ip, ami_id, public_key_path, database credentials, S3 bucket, DynamoDB table)

terraform init -backend-config=backend.hcl
terraform validate
terraform plan
terraform apply
```

After provisioning, configure Ansible inventory and run playbooks against the
approved target hosts.

## GitOps Deployment

Helm charts in `gitops/helm-charts/` are the single source of truth for
Kubernetes workloads. ArgoCD Applications reference these charts and are
organized by environment namespace (dev, test, prod).

Before bootstrap:
1. Verify ArgoCD Application manifests point to your repository.
2. Ensure `targetRevision` matches your active branch.
3. Never hardcode credentials into manifests; use ArgoCD secrets or Vault.

## Security Controls

- **Source control** – Pre-commit hooks block secrets, large files, and merge
  conflicts. Gitleaks scans for leaked credentials.
- **CI gates** – SonarQube quality gate and Trivy HIGH/CRITICAL vulnerability
  scan must pass before image publication.
- **Registry** – ECR scan-on-push and immutable tags are enabled.
- **Runtime** – Workloads run as non-root with dropped Linux capabilities.
- **Pod Security** – Kubernetes restricted profile is enforced.
- **Secrets** – Vault policies grant least-privilege read access to scoped paths.
- **Data** – RDS storage is encrypted with automated backups and deletion
  protection.
- **Dependencies** – Dependabot monitors all ecosystems daily.
- **SBOM** – Software Bills of Materials are generated for every container image.

## Observability

| Signal | Tool | Port |
|--------|------|------|
| Metrics | Prometheus | 9090 |
| Dashboards | Grafana | 3000 |
| Logs | ELK Stack | 5044 / 9200 / 5601 |
| Traces | Tempo | 4317 |
| Cloud | CloudWatch | AWS-native |

See `observability/` for configuration details.

## Operations

Standard procedures are documented in `operations/`:

- `incident-management/` – Incident response workflow
- `change-management/` – Production change approval process
- `rca/` – Root Cause Analysis template and process
- `sop/` – Standard Operating Procedures (backup, rollback, rotation, DR)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for our code of conduct, pull
request process, style guides, and sign-off requirements.

## Security

To report a vulnerability, see [SECURITY.md](SECURITY.md) for contact
information and coordinated disclosure timeline.

## License

This project is licensed under the Apache License 2.0 – see [LICENSE](LICENSE).

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: [https://github.com/HariPolavarapu](https://github.com/HariPolavarapu)
- LinkedIn: [https://linkedin.com/in/hari-krishna-polavarapu](https://linkedin.com/in/hari-krishna-polavarapu)
