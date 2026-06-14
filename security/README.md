# Security

Security configuration for the Hari Enterprise DevOps Platform, covering secrets management, role-based access control, and organisational security policies.

## Overview

| Component | Path | Purpose |
|-----------|------|---------|
| Vault Policies | `vault/policies/` | HashiCorp Vault access control policies |
| Vault Configuration | `vault/config/` | Vault server configuration |
| RBAC Definitions | `rbac/` | Kubernetes Role and RoleBinding manifests |
| Organisation Policies | `policies/` | Namespace and security standards definitions |

## HashiCorp Vault

### Purpose

HashiCorp Vault manages secrets for all environments. Secrets must never be stored in Git, Docker images, Kubernetes manifests, or environment files committed to version control.

### Configuration

Vault server configuration files are stored in `vault/config/`. The configuration follows standard HashiCorp Vault server configuration syntax.

### Policies

Vault policies in `vault/policies/` define fine-grained access control to secrets paths.

#### Available Policies

| Policy File | Purpose |
|-------------|---------|
| `vault.hcl` | Base policy for general secret access |
| `platform-read.hcl` | Read-only access to platform configuration secrets |

#### Applying a Policy

```bash
vault policy write <policy-name> vault/policies/<policy-file>.hcl
```

#### Example: Read-Only Platform Policy

```hcl
path "secret/platform/*" {
  capabilities = ["read", "list"]
}
```

### Secret Management Workflow

1. **Write a secret to Vault:**
   ```bash
   vault kv put secret/platform/<service>/api-key key=<value>
   ```

2. **Read a secret (for deployment injection):**
   ```bash
   vault kv get secret/platform/<service>/api-key
   ```

3. **Reference secrets in Kubernetes:** Use the Vault Secrets Operator or a CSI driver to inject secrets as Kubernetes Secrets. Never commit the secret values.

4. **Rotate secrets:** Update the value in Vault, then restart the consuming service or rely on the CSI driver to reload.

## Kubernetes RBAC

RBAC definitions in `/security/rbac/` control access to Kubernetes resources.

### Platform Reader Role

A read-only role for the `enterprise-platform` namespace that grants `get`, `list`, and `watch` on core Kubernetes resources to the `platform-readers` group.

**File:** `rbac/platform-reader.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: platform-reader
  namespace: enterprise-platform
rules:
  - apiGroups: ["", "apps", "batch"]
    resources: ["pods", "pods/log", "services", "configmaps", "deployments", "jobs"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: platform-reader
  namespace: enterprise-platform
subjects:
  - kind: Group
    name: platform-readers
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: platform-reader
  apiGroup: rbac.authorization.k8s.io
```

**Apply the role:**
```bash
kubectl apply -f security/rbac/platform-reader.yaml
```

### Access Review

RBAC definitions must be reviewed quarterly. See the Access Review SOP in `/operations/sop/` for the full procedure.

## Organisation Policies

### Namespace Definition

**File:** `policies/namespace.yaml`

Defines the `enterprise-platform` namespace with enforced Pod Security Standards.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: enterprise-platform
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**Apply:**
```bash
kubectl apply -f security/policies/namespace.yaml
```

## Security Hardening

### Container Image Scanning

All container images are scanned by Trivy in the CI pipeline (`/cicd/trivy/trivy.yaml`). Images with HIGH or CRITICAL vulnerabilities are blocked from deploying to `test` and `prod` environments.

See `/operations/sop/#vulnerability-remediation` for remediation SLAs.

### Secrets Detection

Pre-commit hooks must be configured to run secret detection before any commit is accepted. The repository root contains a `.pre-commit-config.yaml` with hooks for:
- `detect-private-key` — detects accidental committed private keys.
- `gitleaks` or `detect-secrets` — scans for committed secrets.

Run pre-commit manually before pushing:
```bash
pre-commit run --all-files
```

### Credential Handling Rules

The following rules are mandatory across the entire repository:

- **Never** commit real credentials, access tokens, passwords, or private keys.
- Use `${env.VARIABLE_NAME}` or Vault references for all secrets in configuration.
- The `setup-dev.sh` script auto-generates a local PostgreSQL password — this is for local development only.
- All production credentials must be provisioned and rotated via Vault.

## Access Review Schedule

| Review | Frequency | Owner |
|--------|-----------|-------|
| Kubernetes RBAC | Quarterly | Platform Team |
| Vault Policies | Quarterly | Platform Team |
| Jenkins Credentials | Quarterly | DevOps Team |
| Ansible Inventory | Quarterly | Platform Team |

## Related Documentation

- Incident Management: `/operations/incident-management/`
- Standard Operating Procedures: `/operations/sop/`
- Infrastructure (Terraform for IAM): `/infrastructure/terraform/`
- CI/CD (Trivy scan): `/cicd/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu