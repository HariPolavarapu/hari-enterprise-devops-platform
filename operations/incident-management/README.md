# Incident Management

Enterprise-grade incident response process for the Hari Enterprise DevOps Platform.

## Purpose

This directory defines the structured process for classifying, managing, resolving, and reviewing production incidents. The goal is to restore normal service operation as quickly as possible while preserving an accurate timeline for post-incident analysis.

## Incident Severity Levels

| Level | Definition | Response Time | Examples |
|-------|------------|---------------|----------|
| **SEV-1** | Complete service outage or data loss | 15 minutes | Production down, database unreachable, total data loss |
| **SEV-2** | Major feature unavailable or significant degradation | 30 minutes | Core API returning 5xx for >10% of requests, auth failure |
| **SEV-3** | Minor feature degradation, workaround available | 2 hours | Non-critical service slow, single-region issue |
| **SEV-4** | Cosmetic or low-impact issue | Next business day | UI glitch, non-production environment issue |

## Incident Commander Responsibilities

1. **Classify** the incident severity based on business and customer impact.
2. **Assign** an Incident Commander (IC) if not already assigned.
3. **Preserve** a timestamped timeline of all actions taken.
4. **Stabilise** the service — prioritise mitigation over root cause investigation.
5. **Communicate** status to stakeholders at defined intervals.
6. **Capture** follow-up work as tickets linked to the incident.

## Response Workflow

```
Detect → Classify → Assign IC → Timeline → Mitigate → Resolve → Post-Incident Review
```

### 1. Detection
Incidents may be detected via:
- Observability alerts (Prometheus/Grafana in `/observability/`)
- Customer-reported issue
- On-call rotation

### 2. Classification
Assign one severity level. Re-classify as facts emerge.

### 3. Incident Commander Assignment
- **SEV-1/2**: Must be assigned within 5 minutes of detection.
- **SEV-3/4**: Assign during next business hours or immediately if on-call.

### 4. Timeline Preservation
Record the following in the incident ticket:
- Time of detection
- Time of classification
- Actions taken (with timestamps)
- Communication sent (with timestamps)
- Time of mitigation
- Time of resolution

### 5. Mitigation
- Roll back the offending change if a deployment is suspected.
- Activate runbooks in `/operations/sop/` if a matching procedure exists.
- Engage specialist responders as required (DBA, network, security).

### 6. Resolution
Confirm the service is restored and alert channels are updated.

### 7. Post-Incident Review
- Complete an RCA document in `/operations/rca/`.
- Identify corrective actions with assigned owners and due dates.
- Schedule a blameless post-incident review meeting within 5 business days.

## Roles and Responsibilities

| Role | Responsibility |
|------|---------------|
| **Incident Commander** | Coordinates response, communications, and resolution |
| **Technical Lead** | Drives technical mitigation and investigation |
| **Communications Lead** | Manages stakeholder updates and status page |
| **SME** | Provides domain expertise as needed |

## Security Considerations

- **Never** paste credentials, passwords, API keys, or customer PII into incident tickets or repository files.
- Use the Secrets Management procedure in `/operations/sop/` when access to secrets is required during an incident.
- All incident communications must comply with data classification policies in `/security/policies/`.

## SLA Targets

| Severity | First Response | Mitigation Target | Resolution Target |
|----------|---------------|-------------------|-------------------|
| SEV-1 | 15 min | 1 hour | 4 hours |
| SEV-2 | 30 min | 2 hours | 8 hours |
| SEV-3 | 2 hours | Next business day | 5 business days |
| SEV-4 | Next business day | 5 business days | Next sprint |

## Escalation Path

```
On-call Engineer → Platform Lead → DevOps Manager → CTO
```

## Related Documentation

- Root Cause Analysis: `/operations/rca/`
- Standard Operating Procedures: `/operations/sop/`
- Change Management: `/operations/change-management/`
- Secrets Management SOP: `/operations/sop/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu