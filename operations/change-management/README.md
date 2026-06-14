# Change Management

Enterprise-grade change management process for the Hari Enterprise DevOps Platform. All production changes must follow this process to maintain service stability and auditability.

## Purpose

Define a repeatable, safe process for planning, reviewing, approving, and rolling back changes to production systems. The process minimises risk through peer review, automated validation gates, and explicit rollback readiness.

## Change Categories

| Category | Definition | Approval Required |
|----------|------------|-------------------|
| **Standard** | Planned, low-risk change with established runbook | Platform Owner + Service Owner |
| **Emergency** | Unplanned change required to resolve an active incident | Incident Commander approval, post-change review mandatory |
| **Expedited** | Time-sensitive business need that cannot wait for standard cycle | DevOps Manager + Platform Owner |

## Standard Change Workflow

```
1. Plan → 2. Authorise → 3. Schedule → 4. Implement → 5. Verify → 6. Close
```

### 1. Planning

Before authoring any change:

- **Document the change** in a pull request description or change ticket.
- **Identify the rollback target**: commit SHA, Helm release revision, or database migration rollback script.
- **Assess risk**: evaluate blast radius, dependencies, and back-compatibility.
- **Notify stakeholders** if the change has a user-facing impact window.

### 2. Authorisation

All production changes require:

1. A **pull request** opened against the `main` branch.
2. **CI gates passing**: see `Jenkinsfile` and CI configuration in `/cicd/jenkins/pipelines/`.
3. **Terraform or Helm plan reviewed** by at least one platform owner.
4. Sign-off from both **service owner** and **platform owner**.

For infrastructure changes (Terraform in `/infrastructure/terraform/`):
- A plan output must be posted in the PR before approval.
- The `terraform.tfvars.example` template must be used; no hardcoded real values.

### 3. Scheduling

- Standard changes are scheduled during the **change window** (Tuesday–Thursday, 10:00–16:00 UTC).
- Changes must not be scheduled during:
  - Core business hours for customer-facing services.
  - Holiday periods or end-of-quarter close.
  - Active incident SEV-1/2 states.

### 4. Implementation

- Merge the approved pull request to `main`.
- Monitor the deployment pipeline and ArgoCD sync status in `/gitops/argocd/`.
- For ArgoCD-managed services, the sync is automatic after the Git push; verify the Application status in ArgoCD.

### 5. Verification

Post-deployment verification checklist:

- [ ] Service health checks return `200 OK` — use `scripts/deployment/health-check.sh`.
- [ ] Error rate is within normal baseline.
- [ ] ArgoCD Application shows `Synced` and `Healthy`.
- [ ] Key user journeys complete successfully.
- [ ] Rollback target is confirmed until the change is fully verified.

### 6. Close

Mark the change ticket as resolved with:
- Deployment timestamp
- ArgoCD revision or commit SHA deployed
- Verification outcome

## Emergency Change Process

Emergency changes bypass the standard review process but **must** be followed by a post-change review within 24 hours.

### Process

1. Incident Commander authorises the emergency change.
2. Make the minimal change necessary to restore service.
3. Open a PR immediately after applying the change (even if just to document).
4. Notify platform and service owners via Slack/Teams.
5. Schedule a post-change review within 24 hours.
6. Complete a formal change record and RCA if applicable.

### Constraints

- Emergency changes must still target a rollback point.
- No new credentials or secrets may be introduced without being recorded in Vault (`/security/vault/`).
- Security-related emergency changes require Security team sign-off.

## Roles and Responsibilities

| Role | Responsibility |
|------|---------------|
| **Change Author** | Authors the change, PR, and rollback plan |
| **Service Owner** | Approves changes to their service |
| **Platform Owner** | Approves infrastructure and cross-service changes |
| **Incident Commander** | Authorises emergency changes during incidents |
| **DevOps Manager** | Approves expedited changes and escalations |

## Environments

The platform manages three environments:

| Environment | Namespace | ArgoCD Project | Approval Tier |
|-------------|-----------|---------------|---------------|
| `dev` | `enterprise-platform-dev` | `dev` | Auto-sync |
| `test` | `enterprise-platform-test` | `test` | Auto-sync with scan gate |
| `prod` | `enterprise-platform-prod` | `prod` | Manual approval required |

ArgoCD Application definitions are located in `/gitops/argocd/{dev,test,prod}/`.

## Rollback

### Helm Rollback

```bash
helm rollback <release-name> -n <namespace>
```

### ArgoCD Rollback

Rollback is performed by syncing to a previous commit in Git. ArgoCD Application revision history is limited to 10 revisions (`revisionHistoryLimit: 10`).

### Terraform Rollback

Terraform state rollbacks require manual intervention. Never run `terraform apply` manually on production. Use the CI pipeline only.

## Related Documentation

- ArgoCD Setup: `/gitops/argocd/`
- Standard Operating Procedures: `/operations/sop/`
- Incident Management: `/operations/incident-management/`
- Terraform Infrastructure: `/infrastructure/terraform/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu