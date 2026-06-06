# Hari Enterprise DevOps Platform

Enterprise-grade monorepo for multi-service applications, infrastructure-as-code, CI/CD, GitOps, observability, and security.

## Structure

| Directory | Purpose |
|-----------|---------|
| `applications/` | Frontend (Angular) and backend microservices (Java, Python, .NET) |
| `infrastructure/` | Terraform, Ansible, and Kubernetes cluster bootstrap |
| `cicd/` | Jenkins, GitHub Actions, SonarQube, Trivy, Nexus |
| `gitops/` | ArgoCD applications, Helm charts, and overlays |
| `observability/` | Prometheus, Grafana, ELK, Tempo, Loki |
| `security/` | Vault, TLS, RBAC, policies, scanning |
| `databases/` | PostgreSQL and MySQL init, migrations, backups |
| `operations/` | Runbooks, SOPs, incident and change management |
| `testing/` | Performance, load, chaos, and security testing |
| `tools/` | CLI wrappers and platform tooling scripts |

## Quick Start

```bash
# Terraform (dev)
make tf-init ENV=dev
make tf-plan ENV=dev
```
