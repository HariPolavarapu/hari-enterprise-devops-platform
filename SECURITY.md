# Security Policy

This document outlines the security policy for the Enterprise DevOps Platform,
including supported versions, how to report vulnerabilities, and our coordinated
disclosure timeline.

## Supported Versions

We release security patches for the following versions. Versions not listed here
are no longer maintained and will not receive security updates.

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| < latest| :x:                |

> **Note:** This repository is a reference implementation. Organizations forking
> or extending it should establish their own support and versioning policies.

## Reporting a Vulnerability

If you believe you have found a security vulnerability in this repository,
**please do not open a public issue**. Instead, report it privately so we can
investigate and remediate before public disclosure.

### How to Report

1. **GitHub Private Vulnerability Reporting** (preferred)
   - Navigate to the repository's **Security → Advisories** tab.
   - Click **Report a vulnerability** and follow the template.

2. **Email** (alternative)
   - Send an encrypted email to: `security@your-org.example`
   - Include a descriptive subject line: `[SECURITY] Brief description`
   - Provide detailed reproduction steps, impact assessment, and suggested
     mitigations if known.

### What to Include

- A clear description of the vulnerability and its potential impact.
- Steps to reproduce the issue (proof-of-concept, commands, or screenshots).
- Affected components, files, or configurations.
- Any suggested fixes or workarounds.
- Your preferred disclosure timeline (see below).

## Disclosure Timeline

We follow a **90-day coordinated disclosure** policy:

| Day | Action |
| --- | ------ |
| 0   | Vulnerability reported and acknowledged within 5 business days. |
| 1–30| Investigation and validation. We may request additional information. |
| 30–60| Development and testing of a fix. A CVE ID may be requested if warranted. |
| 60–90| Patch release and public advisory publication. |
| 90+   | If a fix cannot be released within 90 days, we will communicate the delay, expected timeline, and any available workarounds. |

We reserve the right to adjust this timeline based on severity, exploitability,
and availability of a safe workaround, but we will always communicate any changes
to the reporter.

## Security Considerations for Adopters

When deploying this platform in your own environment, ensure the following
baseline controls are in place:

- **Secrets Management:** Use a secrets manager (e.g., HashiCorp Vault, AWS
  Secrets Manager, or Azure Key Vault) for all credentials, tokens, and keys.
  Never commit secrets to source control.
- **Network Segmentation:** Restrict security-group and firewall rules to the
  minimum required CIDR ranges. Avoid `0.0.0.0/0` ingress for management ports.
- **Image Scanning:** Continuously scan container images for CVEs before and
  after deployment. Block deployments with HIGH/CRITICAL findings.
- **Least Privilege:** Grant IAM, Kubernetes RBAC, and Vault policies on a
  least-privilege basis. Regularly audit and revoke unused permissions.
- **Encryption:** Enable encryption at rest (RDS, EBS, S3) and in transit
  (TLS 1.2+). Rotate encryption keys on a documented schedule.
- **Monitoring:** Forward audit logs to a SIEM. Alert on brute-force attempts,
  privilege escalation, and anomalous API activity.
- **Dependency Updates:** Enable automated dependency scanning and apply security
  patches within 30 days of release.

## Past Advisories

No security advisories have been published for this reference implementation.
When advisories are published, they will be listed in the repository's
**Security → Advisories** tab.

## Acknowledgments

We thank the security research community for responsibly reporting
vulnerabilities. If you report a confirmed vulnerability, we are happy to
publicly acknowledge your contribution in the advisory (with your consent).

---

*Last updated: 2026-06-14*
