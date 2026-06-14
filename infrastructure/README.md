# Infrastructure

Infrastructure-as-Code for the Hari Enterprise DevOps Platform, covering AWS resource provisioning via Terraform and host configuration via Ansible.

## Overview

| Component | Path | Purpose |
|-----------|------|---------|
| Terraform | `terraform/` | AWS infrastructure: VPC, EKS, RDS, ECR, IAM, Route53, CloudWatch |
| Ansible | `ansible/` | Host provisioning and configuration for DevOps, monitoring, and services |

## Terraform

All Terraform configuration uses a modular structure. The root module in `terraform/` composes the following child modules defined under `terraform/modules/`:

### Module Inventory

| Module | Path | Resources Created |
|--------|------|------------------|
| VPC | `modules/vpc/` | Virtual Private Cloud, public and private subnets, NAT Gateways, Internet Gateways, route tables |
| IAM | `modules/iam/` | IAM roles for EKS cluster and node execution |
| EC2 | `modules/ec2/` | DevOps jump host EC2 instance with SSM session support |
| EKS | `modules/eks/` | Amazon EKS cluster and managed node groups |
| ECR | `modules/ecr/` | Elastic Container Registry repositories for all services |
| RDS | `modules/rds/` | Amazon RDS PostgreSQL instance in private subnets with automated backups |
| Route53 | `modules/route53/` | Route53 records for Jenkins and internal services |
| CloudWatch | `modules/cloudwatch/` | CloudWatch log groups and basic monitoring configuration |
| Security Groups | (inlined in `main.tf`) | Security groups for DevOps VM (port 22) and RDS (port 5432) |

### Root Module Composition

The root `main.tf` wires together all modules:

```hcl
module "vpc"       { source = "./modules/vpc"       ... }
module "eks"       { source = "./modules/eks"       ... }
module "rds"       { source = "./modules/rds"       ... }
module "ec2"       { source = "./modules/ec2"       ... }
module "ecr"       { source = "./modules/ecr"       ... }
module "iam"       { source = "./modules/iam"       ... }
module "route53"   { source = "./modules/route53"   ... }
module "cloudwatch"{ source = "./modules/cloudwatch"... }
```

### Configuration Files

| File | Purpose |
|------|---------|
| `main.tf` | Root module composition — instantiates all child modules |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output value definitions |
| `versions.tf` | Provider version constraints |
| `provider.tf` | AWS provider configuration |
| `backend.hcl.example` | Example Terraform backend configuration (S3 + DynamoDB) |
| `terraform.tfvars.example` | Example variable values — copy to `terraform.tfvars` and fill in |

### Backend Configuration

Terraform state is stored in S3 with DynamoDB state locking. Use the provided example:

```bash
cp backend.hcl.example backend.hcl
# Edit backend.hcl with your bucket and DynamoDB table names
terraform init -backend-config=backend.hcl
```

### Required Variables

| Variable | Description | Source |
|----------|-------------|--------|
| `project_name` | Prefix for all resource names | User-provided |
| `vpc_cidr` | VPC CIDR block | User-provided |
| `public_subnet_cidrs` | Public subnet CIDRs | User-provided |
| `private_subnet_cidrs` | Private subnet CIDRs | User-provided |
| `availability_zones` | AZs for subnets | User-provided |
| `ami_id` | AMI for DevOps EC2 instance | User-provided |
| `my_ip` | Your IP for SSH access to DevOps host | User-provided |
| `database_username` | RDS master username | User-provided |
| `database_password` | RDS master password | User-provided |
| `public_key_path` | Path to SSH public key | User-provided |

### Security Considerations

- **Never commit `terraform.tfvars`** — it may contain `database_password` and other secrets. It is excluded from version control.
- Database password is passed as a variable; use a secrets manager or Vault to inject it in CI.
- SSH access to the DevOps host is restricted to `my_ip` via the security group rule.

### Terraform Workflow

```bash
# Initialise
terraform init -backend-config=backend.hcl

# Plan (review the output before applying)
terraform plan -var-file=terraform.tfvars

# Apply (CI should use the pipeline, not manual apply)
terraform apply -var-file=terraform.tfvars

# Destroy (use with caution — destroys all managed resources)
terraform destroy -var-file=terraform.tfvars
```

### Outputs

Key outputs from `outputs.tf` include EKS cluster endpoint, ECR repository URLs, RDS endpoint, and DevOps instance public IP. Read them with `terraform output`.

## Ansible

Ansible provides idempotent configuration management for all platform hosts. It uses an inventory-based approach with roles for each component.

### Inventory

**File:** `ansible/inventories/hosts.ini`

A template inventory for defining target hosts. The file contains commented-out example entries:

```ini
[devops]
# devops-host ansible_host=<YOUR_DEVOPS_HOST> ansible_user=ubuntu

[monitoring]
# monitoring-host ansible_host=<YOUR_MONITORING_HOST> ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

**Security note:** Do not commit real host IPs or credentials to version control. Replace the commented examples with your actual host details, but do so in a way that excludes the file from version control or use Ansible Vault for credentials.

### Playbooks

Each playbook targets a specific component:

| Playbook | Target | Purpose |
|----------|--------|---------|
| `common.yml` | All hosts | Base configuration (OS updates, packages) |
| `docker.yml` | All hosts | Docker Engine installation |
| `jenkins.yml` | Jenkins host | Jenkins installation and configuration |
| `kubernetes.yml` | K8s nodes | Kubernetes node setup |
| `monitoring.yml` | Monitoring host | Prometheus/Grafana stack |
| `nexus.yml` | Nexus host | Nexus Repository Manager setup |
| `sonarqube.yml` | SonarQube host | SonarQube installation |
| `vault.yml` | Vault host | HashiCorp Vault installation and configuration |

### Roles

Each playbook uses one or more roles from `ansible/roles/`:

| Role | Purpose |
|------|---------|
| `common` | OS-level base configuration |
| `docker` | Docker Engine and Docker Compose |
| `jenkins` | Jenkins agent configuration |
| `kubernetes` | Kubernetes node components |
| `monitoring` | Prometheus and Grafana |
| `nexus` | Nexus Repository Manager |
| `sonarqube` | SonarQube |
| `vault` | HashiCorp Vault server |

### Ansible Requirements

```bash
# Install required collections
ansible-galaxy collection install -r requirements.yml
# or
ansible-galaxy role install -r requirements.yml
```

### Running Playbooks

```bash
# Run a single playbook against a specific inventory
ansible-playbook -i inventories/hosts.ini playbooks/jenkins.yml

# Run with privilege escalation
ansible-playbook -i inventories/hosts.ini playbooks/vault.yml --ask-become-pass

# Run with tags
ansible-playbook -i inventories/hosts.ini playbooks/common.yml --tags=packages
```

## Related Documentation

- Standard Operating Procedures: `/operations/sop/`
- Change Management: `/operations/change-management/`
- CI/CD (Jenkins): `/cicd/`
- Security (Vault, RBAC): `/security/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu