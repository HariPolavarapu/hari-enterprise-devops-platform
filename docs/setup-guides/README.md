# Setup Guide

This document describes the complete setup process for the Enterprise DevOps
Platform, from installing prerequisites to provisioning AWS infrastructure
and verifying the local development environment.

---

## Overview

The platform supports two modes of operation:

- **Local development** — Docker Compose for all services, no AWS dependency
- **Cloud deployment** — Terraform provisioning on AWS followed by GitOps deployment

---

## Prerequisites

### Required for Local Development

| Tool         | Minimum Version | Install Guide                               |
|--------------|-----------------|---------------------------------------------|
| Git          | 2.40+           | https://git-scm.com/downloads               |
| Docker       | 24.0+           | https://docs.docker.com/get-docker/         |
| Docker Compose | v2.20+        | https://docs.docker.com/compose/install/    |
| Make         | Any recent      | Pre-installed on macOS/Linux                |

### Required for Cloud Deployment

| Tool         | Minimum Version | Install Guide                               |
|--------------|-----------------|---------------------------------------------|
| Terraform    | 1.5+            | https://developer.hashicorp.com/terraform/downloads |
| AWS CLI      | 2.x             | https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html |
| kubectl      | 1.28+           | https://kubernetes.io/docs/tasks/tools/     |
| Helm         | 3.12+           | https://helm.sh/docs/intro/install/         |
| Ansible      | 2.15+           | https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html |

### Required for Application Development

| Tool         | Minimum Version | Install Guide                               |
|--------------|-----------------|---------------------------------------------|
| Java         | 17              | https://adoptium.net/                       |
| Maven        | 3.9+            | https://maven.apache.org/install.html       |
| Python       | 3.12            | https://www.python.org/downloads/           |
| .NET SDK     | 8.0             | https://dotnet.microsoft.com/download       |
| Node.js      | 20.x LTS        | https://nodejs.org/en/download/             |

---

## Local Development Setup

### Step 1 — Clone the Repository

```bash
git clone https://github.com/HariPolavarapu/hari-enterprise-devops-platform.git
cd hari-enterprise-devops-platform
```

### Step 2 — Configure Environment Variables

Copy the example environment file and fill in required values:

```bash
cp .env.example .env
```

Edit `.env` and set at minimum:

```bash
# Required: PostgreSQL password (must be set, no default)
DB_PASSWORD=your-secure-password-here

# Optional: Override defaults
DB_USER=app_user
SMTP_HOST=mail
SMTP_PORT=1025
```

> **Security Note:** The `.env` file is gitignored and must never be committed.
> Use a secrets manager (AWS Secrets Manager, HashiCorp Vault) for production.

### Step 3 — Start the Local Stack

```bash
make up
```

This runs `docker compose up --build` to build and start all services.
To start in detached mode:

```bash
make up DOCKER_COMPOSE_FLAGS="-d"
```

### Step 4 — Verify Services Are Running

```bash
make logs

# Or check individually
docker compose ps

# Health check each service
curl -sf http://localhost:8080/actuator/health   # Employee Service
curl -sf http://localhost:8081/health            # Notification Service
curl -sf http://localhost:8082/health            # Payroll Service
curl -sf http://localhost:4200                   # Frontend
```

Expected output: HTTP 200 with a JSON health response body.

### Step 5 — Stop the Local Stack

```bash
make down
```

### Make Targets Reference

| Command           | Description                                     |
|-------------------|-------------------------------------------------|
| `make validate`   | Run all validations (Terraform, Helm, tests)    |
| `make test`       | Run application unit tests for all services     |
| `make build`      | Build Docker images locally                     |
| `make up`         | Start the local Docker Compose stack            |
| `make down`       | Stop and remove the local stack                 |
| `make logs`       | Stream logs from all services                   |
| `make terraform-validate` | Validate Terraform configuration          |
| `make helm-lint`  | Lint all Helm charts                            |

---

## AWS Cloud Setup

### Step 1 — Configure AWS Credentials

```bash
aws configure
# Enter your Access Key ID, Secret Access Key, region (e.g., us-east-1), and output format
```

Or use a named profile:

```bash
export AWS_PROFILE=your-profile-name
```

### Step 2 — Copy and Configure Terraform Variables

```bash
cd infrastructure/terraform

# Copy example configuration files
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
```

Edit `terraform.tfvars` with your environment values:

```hcl
project_name        = "enterprise-devops"
my_ip               = "203.0.113.42/32"          # Your public IP for SSH access
ami_id              = "ami-0abcdef1234567890"    # Amazon Linux 2023 AMI in your region
public_key_path     = "~/.ssh/id_ed25519.pub"    # Path to your public key
database_username   = "app_admin"                # RDS master username
database_password   = "your-secure-db-password"  # RDS master password (use Secrets Manager in prod)
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
```

Edit `backend.hcl` with your S3 backend configuration:

```hcl
bucket = "your-terraform-state-bucket"
key    = "devops-platform/terraform.tfstate"
region = "us-east-1"
dynamodb_table = "terraform-state-lock"
```

> **Warning:** Never commit `terraform.tfvars` or `backend.hcl`. Ensure they are
> listed in `.gitignore`. Use AWS Secrets Manager or environment variables for
> sensitive values in production.

### Step 3 — Provision Infrastructure

```bash
cd infrastructure/terraform

# Initialize Terraform with the backend configuration
terraform init -backend-config=backend.hcl

# Validate the configuration
terraform validate

# Preview the execution plan
terraform plan

# Apply the configuration (creates AWS resources)
terraform apply

# Save the output for Ansible
terraform output --json > ../ansible/inventories/aws-output.json
```

Resources provisioned include: VPC, EKS cluster, ECR repositories, RDS
PostgreSQL, EC2 bastion host, IAM roles, security groups, Route 53 records,
and CloudWatch log groups.

### Step 4 — Configure Jenkins Credentials

Review the root `Jenkinsfile` for all credential IDs required:

| Credential ID          | Description                              |
|------------------------|------------------------------------------|
| `aws-region`           | AWS region (e.g., `us-east-1`)           |
| `aws-account-id`       | 12-digit AWS account ID                  |
| `sonarqube`            | SonarQube environment configuration      |
| `nexus-credentials`    | Nexus username and password              |

Configure these in Jenkins → Manage Jenkins → Credentials before running any
pipeline.

### Step 5 — Run Ansible Playbooks

```bash
cd infrastructure/ansible

# Update the inventory with actual target hosts from Terraform output
# Edit inventories/hosts.ini with the EC2 bastion host IP

# Run the base setup playbook
ansible-playbook -i inventories/hosts.ini playbooks/base.yml

# Run the Jenkins setup playbook (if deploying Jenkins)
ansible-playbook -i inventories/hosts.ini playbooks/jenkins.yml
```

### Step 6 — Verify ArgoCD Configuration

```bash
# Check ArgoCD Application manifests
cat gitops/argocd/applications.yml

# Verify repository URL and targetRevision are correct
# Update if using a fork of this repository
argocd repo list
argocd app list
```

---

## Running the Full Validation Suite

```bash
# Run all validations (Terraform fmt, Helm lint, application tests)
make validate

# Individual Terraform validation
make terraform-validate

# Individual Helm lint
make helm-lint

# Individual test runs
make test
```

Expected results:
- `terraform validate` exits `0` with no errors
- `helm lint` reports no errors for any chart
- All application tests pass

---

## Docker Compose Test File

A separate `docker-compose.test.yml` is provided for CI testing environments.
It uses environment-driven credentials and does not include hardcoded passwords.
Run it for integration testing:

```bash
docker compose -f docker-compose.test.yml up --build --abort-on-container-exit
```

---

## Common Setup Issues

| Issue                          | Resolution                                        |
|--------------------------------|---------------------------------------------------|
| `DB_PASSWORD must be set`      | Set `DB_PASSWORD` in `.env` before running `make up` |
| Docker build fails             | Ensure Docker daemon is running; increase Docker resources |
| Terraform init fails           | Verify AWS credentials with `aws sts get-caller-identity` |
| Ansible cannot reach host      | Verify the EC2 instance is reachable from your IP and the bastion SG allows SSH |
| ArgoCD app out of sync         | Check the repository URL and `targetRevision` in the Application manifest |
| kubectl not configured         | Run `aws eks update-kubeconfig --name <cluster-name>` to update kubeconfig |

---

## Next Steps

After setup is complete:

1. Review [Architecture Overview](../architecture/README.md) for component details
2. Review [Deployment Guide](../deployment-guides/README.md) for release process
3. Review [Troubleshooting Guide](../troubleshooting/README.md) for common issues
4. Read the [CONTRIBUTING.md](../../CONTRIBUTING.md) before making changes

---

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu