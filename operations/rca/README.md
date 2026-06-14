# Root Cause Analysis

Post-incident Root Cause Analysis (RCA) process for the Hari Enterprise DevOps Platform. RCAs are conducted after every SEV-1 and SEV-2 incident, and optionally for SEV-3 incidents at the platform owner's discretion.

## Purpose

Identify and document the contributing conditions and root cause of an incident in a blameless manner. The output is a corrective action plan with measurable outcomes, aimed at preventing recurrence.

## When to Conduct an RCA

| Severity | RCA Required | Timeline |
|----------|-------------|----------|
| SEV-1 | **Yes** | Within 5 business days of resolution |
| SEV-2 | **Yes** | Within 5 business days of resolution |
| SEV-3 | Optional | At platform owner's discretion |
| SEV-4 | No | Not required |

## RCA Process

```
1. Trigger → 2. Timeline Reconstruction → 3. Root Cause Analysis → 4. Corrective Actions → 5. Review
```

### 1. Trigger

An RCA is triggered by:
- SEV-1 or SEV-2 incident resolution.
- DevOps Manager or Platform Owner request.
- Recurring SEV-3 incidents (3+ in 30 days).

The RCA document is stored in this directory with naming convention: `rca-<YYYYMMDD>-<incident-id>.md`

### 2. Timeline Reconstruction

Using the incident ticket timeline and available evidence:

- **Detection time**: When the alert fired or customer reported the issue.
- **MTTR (Mean Time to Resolve)**: Difference between detection and resolution.
- **Key events**: Deployment, configuration change, or infrastructure event that preceded the incident.
- **Notifications**: When stakeholders were informed and by whom.

Sources to consult:
- ArgoCD Application sync history in `/gitops/argocd/`
- Jenkins pipeline run history in `/cicd/jenkins/pipelines/`
- Kubernetes pod logs via `kubectl logs`
- CloudWatch / observability dashboards in `/infrastructure/terraform/modules/cloudwatch/`

### 3. Root Cause Analysis

Use the **5 Whys** technique or **Ishikawa (Fishbone)** diagram to identify the root cause.

#### Categories of Contributing Conditions

- **People**: Procedure not followed, miscommunication, missing training.
- **Process**: No runbook existed, change management gap, insufficient testing.
- **Technology**: Bug in code, misconfigured infrastructure, dependency failure.
- **Environment**: Network issue, cloud provider incident, capacity exhaustion.

#### Blameless Principle

Focus on system controls and process failures. The goal is to identify what allowed the incident to happen, not who caused it. Individuals are not named as root causes.

### 4. Corrective Actions

Every RCA must include at least one corrective action. Actions must be:

- **Specific**: What exactly will be done?
- **Measurable**: How will success be determined?
- **Assigned**: Who owns the action?
- **Dated**: Target completion date.

#### Example Corrective Action Template

| Action | Owner | Due Date | Success Metric |
|--------|-------|----------|----------------|
| Add automated health check for X | SRE Team | YYYY-MM-DD | Alert fires within 2 min of X failure |
| Harden pre-commit secret scanning | Platform Team | YYYY-MM-DD | Zero secrets in CI for 30 days |
| Document rollback procedure for service Y | Service Owner | YYYY-MM-DD | Runbook in `/operations/sop/` |

### 5. Review

- The completed RCA is reviewed by the Platform Owner and DevOps Manager.
- Corrective actions are tracked in the project issue tracker.
- A blameless post-incident review meeting is held within 5 business days of incident resolution.

## RCA Document Structure

```markdown
# RCA: <Incident Title>
**Date**: YYYY-MM-DD
**Severity**: SEV-X
**Incident Commander**: <Name>
**Affected Services**: <list>

## Summary
One-paragraph description of the incident and its impact.

## Impact
- Users affected: <number or description>
- Revenue / SLA impact: <if applicable>
- Duration: <start> to <end>

## Timeline
| Time (UTC) | Event |
|------------|-------|
| HH:MM | Description |

## Root Cause
Contributing conditions and root cause.

## Corrective Actions
| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| ... | ... | ... | Open/Done |

## Lessons Learned
What went well? What could be improved?
```

## Related Documentation

- Incident Management: `/operations/incident-management/`
- Standard Operating Procedures: `/operations/sop/`
- Observability (logging, metrics): `/observability/`
- ArgoCD for deployment history: `/gitops/argocd/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu