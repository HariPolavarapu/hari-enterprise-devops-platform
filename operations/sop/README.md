# Standard Operating Procedures

Operational runbooks and procedures for the Hari Enterprise DevOps Platform. These SOPs define the step-by-step instructions for routine operations, including deployment verification, rollback, backup validation, access review, and disaster recovery testing.

## Purpose

Provide authoritative, tested procedures for common operational tasks. All SOPs must be executed against an explicitly specified environment. Production procedures must never be run against development environments without explicit scope.

## Scope

These procedures cover:
- Deployment verification
- Rollback execution
- Database backup validation
- Access review
- Vulnerability remediation
- Certificate rotation
- Disaster recovery testing

## Deployment Verification

Run after every production deployment to confirm the service is healthy.

### Prerequisites

- `kubectl` configured for the target cluster.
- ArgoCD CLI (`argocd`) installed and authenticated.
- Access to the target namespace.

### Procedure

```bash
# 1. Verify ArgoCD Application status
argocd app get <app-name> -n argocd

# 2. Check pod status in target namespace
kubectl get pods -n <namespace>

# 3. Run health check script
bash scripts/deployment/health-check.sh

# 4. Verify sync status
argocd app sync <app-name> --force --wait -n argocd
```

### Success Criteria

- All pods in `Running` or `Completed` state.
- No pod restarts in the last 5 minutes.
- Health check script returns `200 OK` for all service endpoints.
- ArgoCD Application shows `Synced` and `Healthy`.

## Rollback

### Helm Release Rollback

```bash
# List release history
helm history <release-name> -n <namespace>

# Rollback to previous revision
helm rollback <release-name> -n <namespace>

# Rollback to specific revision
helm rollback <release-name> <revision> -n <namespace>
```

### ArgoCD Rollback

Since ArgoCD syncs from Git, rollback is performed by reverting to the desired commit and triggering a sync:

```bash
# Revert to previous commit (local)
git revert HEAD
git push origin main

# Or target a specific previous revision
git checkout <desired-sha>
git push origin <desired-sha>

# Trigger ArgoCD sync
argocd app sync <app-name> -n argocd
```

### Verification Post-Rollback

After rolling back, re-run the Deployment Verification procedure to confirm health.

## Database Backup Validation

### Prerequisites

- Access to the RDS instance via the DevOps VM.
- `psql` client installed.
- Backup retention policy configured in `/infrastructure/terraform/modules/rds/`.

### Procedure

```bash
# Connect to the RDS instance via bastion
psql -h <rds-endpoint> -U <db_user> -d <db_name>

# Verify backup chain (run on RDS instance)
SELECT pg_backup_start_time(), pg_backup_stop_time();

# Confirm recent automated backups exist
SELECT * FROM pg_stat_bgwriter;
```

### Acceptance Criteria

- Automated backup completed within the last 24 hours.
- Point-in-time recovery is enabled for all production databases.
- Backup restoration has been tested in the last 90 days (see DR Testing SOP).

## Access Review

Perform quarterly access reviews for all platform components.

### Scope

- Kubernetes RBAC roles defined in `/security/rbac/`
- Vault policies defined in `/security/vault/policies/`
- Jenkins credentials and user accounts in `/cicd/jenkins/`
- Ansible inventory users in `/infrastructure/ansible/inventories/`

### Procedure

1. Export current access list from each system.
2. Compare against the last review's access list.
3. Identify accounts with access but no recent activity (90+ days).
4. Revoke orphaned or unnecessary accounts.
5. Update RBAC definitions in `/security/rbac/` for any changes.
6. Document findings in the access review ticket.

### Platform Reader Role

A read-only role is pre-defined for the `enterprise-platform` namespace:

```bash
kubectl apply -f security/rbac/platform-reader.yaml
```

This grants `get`, `list`, `watch` on core Kubernetes resources to the `platform-readers` group.

## Vulnerability Remediation

### Severity-Based SLAs

| Severity | Remediate By |
|----------|-------------|
| CRITICAL | 24 hours |
| HIGH | 7 days |
| MEDIUM | 30 days |
| LOW | Next sprint |

### Procedure

1. Review Trivy scan results from CI pipeline (`/cicd/trivy/trivy.yaml`).
2. For CRITICAL/HIGH vulnerabilities in production images:
   - Pin the base image to a specific SHA, not a floating tag.
   - Rebuild the image after the upstream fix is released.
3. Update Helm values to use the new image tag.
4. ArgoCD will auto-sync on the next push to `main`.
5. Verify the new image is running with no new vulnerabilities.

### Preventing New Vulnerabilities

- All images must pass Trivy CI scan before deployment: `trivy image --exit-code 1 --severity HIGH,CRITICAL`.
- See `/cicd/trivy/trivy.yaml` for the configured scan policy.

## Certificate Rotation

### TLS Certificates for Ingress

Certificates are managed via Kubernetes Ingress with cert-manager or manually via Kubernetes Secret.

#### Manual Rotation

```bash
# Check certificate expiry
kubectl get certificate -n <namespace> -o wide

# If using a TLS Secret directly:
kubectl create secret tls <secret-name> \
  --cert=<path-to-cert> --key=<path-to-key> \
  -n <namespace> --dry-run=client -o yaml | kubectl apply -f -

# Verify
kubectl get secret <secret-name> -n <namespace>
```

### Vault Certificates

If Vault PKI is used, certificates are managed through Vault's PKI secrets engine. Follow the rotation policy defined in `/security/vault/policies/`.

## Disaster Recovery Testing

### Frequency

Disaster recovery (DR) tests must be performed at minimum **annually**, or after any significant infrastructure change.

### Scope

- Database restoration from backup (RDS point-in-time recovery).
- ArgoCD application state restoration.
- Infrastructure recreation from Terraform state in `/infrastructure/terraform/`.

### DR Test Procedure

1. **Notify** stakeholders of planned DR test window.
2. **Backup**: Capture current RDS snapshot.
3. **Destroy**: Remove the target environment namespace.
4. **Restore**: Redeploy via ArgoCD from Git (`/gitops/argocd/`).
5. **Restore DB**: Restore RDS from automated snapshot.
6. **Verify**: Run health checks and confirm service functionality.
7. **Document**: Record RTO (Recovery Time Objective) and RPO (Recovery Point Objective).

### RTO / RPO Targets

| System | RTO | RPO |
|--------|-----|-----|
| Core API Services | 30 min | 1 hour |
| Database | 1 hour | 1 hour |
| Frontend | 15 min | N/A |

## Environment Specification

**All commands must include an explicit environment target.** Never run operational commands without specifying the target namespace or environment.

```bash
# Explicit environment — correct
kubectl get pods -n enterprise-platform-prod

# No environment specified — incorrect, do not use
kubectl get pods
```

## Related Documentation

- Incident Management: `/operations/incident-management/`
- Change Management: `/operations/change-management/`
- ArgoCD Setup: `/gitops/argocd/`
- Infrastructure (Terraform): `/infrastructure/terraform/`
- Security (Vault, RBAC): `/security/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu