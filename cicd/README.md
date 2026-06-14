# CI/CD

Continuous Integration and Continuous Delivery configuration for the Hari Enterprise DevOps Platform. This directory contains pipeline definitions for Jenkins, repository configuration for Nexus artifact management, and security scanning policies.

## Overview

| Component | Path | Purpose |
|-----------|------|---------|
| Jenkins Pipelines | `jenkins/pipelines/` | Declarative pipeline definitions for CI |
| Nexus Configuration | `nexus/settings.xml` | Maven artifact repository settings |
| Trivy Policy | `trivy/trivy.yaml` | Container image vulnerability scan configuration |

## Jenkins Pipelines

### servicePipeline.groovy

A declarative Jenkins pipeline that builds, tests, and scans each service. The pipeline is triggered per service based on the `JOB_NAME`.

**Supported services and build commands:**

| Service | Path | Build Command |
|---------|------|---------------|
| `employee-service` | `applications/employee-java-service` | `mvn -B clean verify` |
| `notification-service` | `applications/notification-python-service` | `pip install -r requirements.txt && pytest` |
| `payroll-service` | `applications/payroll-dotnet-service` | `dotnet build --configuration Release` |
| `frontend` | `applications/frontend-angular` | `npm install && npm run build` |

**Pipeline stages:**

1. **Build and Test** — Runs the language-appropriate build and test command for the service.
2. **Build Image** — Builds a Docker image tagged with `${servicePath}:${BUILD_NUMBER}`.
3. **Scan Image** — Runs Trivy vulnerability scan; blocks the pipeline on HIGH or CRITICAL findings.

**Jenkins Job Naming Convention:**

Jenkins jobs must be named exactly as they appear in the `services` map in `servicePipeline.groovy` (e.g., `employee-service`, `notification-service`, `payroll-service`, `frontend`). Job names that do not match any key in the map will cause the pipeline to fail with an `Unsupported service job` error.

**Trivy Scan Gate:**

The Trivy stage uses the following policy from `trivy/trivy.yaml`:
- Fails the build on HIGH or CRITICAL unfixed vulnerabilities.
- Scanners enabled: `vuln`, `secret`, `misconfig`.
- Timeout: 10 minutes.

## Nexus Configuration

### settings.xml

Maven `settings.xml` for authenticating with a Nexus repository. This file is located at `nexus/settings.xml`.

**Authenticated server:**
- **ID:** `nexus-releases`
- **Credentials:** Pulled from environment variables `${env.NEXUS_USERNAME}` and `${env.NEXUS_PASSWORD}` — never hardcoded.
- **Repository URL:** Configured via `${env.NEXUS_URL}/repository/maven-releases/`

**Usage:**

Reference this file in your Maven invocation:

```bash
mvn -s cicd/nexus/settings.xml clean deploy
```

Or set it as the default Maven user settings by setting `MAVEN_SETTINGS` in your CI environment.

**Security note:** Credentials must be injected as environment variables in the Jenkins job configuration. Do not hardcode `NEXUS_USERNAME` or `NEXUS_PASSWORD` in any committed file.

## Trivy Configuration

### trivy.yaml

Trivy inline configuration file defining the scan policy applied by the CI pipeline.

**Configuration:**

```yaml
severity:
  - HIGH
  - CRITICAL
ignore-unfixed: true
exit-code: 1
scanners:
  - vuln
  - secret
  - misconfig
timeout: 10m
```

| Setting | Value | Meaning |
|---------|-------|---------|
| `severity` | `HIGH`, `CRITICAL` | Only block on these severity levels |
| `ignore-unfixed` | `true` | Do not fail on unfixed vulnerabilities |
| `exit-code` | `1` | Non-zero exit when vulnerabilities found — triggers CI failure |
| `scanners` | `vuln`, `secret`, `misconfig` | Enable all three scanner types |
| `timeout` | `10m` | Maximum scan duration |

## Adding a New Service

To add a new service to the Jenkins pipeline:

1. Add the service to the `services` map in `jenkins/pipelines/servicePipeline.groovy`:

   ```groovy
   def services = [
     'employee-service':    'applications/employee-java-service',
     'notification-service': 'applications/notification-python-service',
     'payroll-service':    'applications/payroll-dotnet-service',
     'frontend':           'applications/frontend-angular',
     'your-new-service':   'applications/your-new-service'
   ]
   ```

2. Add the build command for your service in the `stage('Build and test')` block:

   ```groovy
   if (servicePath == 'your-new-service') sh '<your-build-command>'
   ```

3. Create a Jenkins job named `your-new-service` or update the multi-branch pipeline configuration to discover the new branch.

## Related Documentation

- ArgoCD GitOps: `/gitops/argocd/`
- Deployment Scripts: `/scripts/deployment/`
- Vulnerability Remediation SOP: `/operations/sop/`
- Security (Trivy, Vault, RBAC): `/security/`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu