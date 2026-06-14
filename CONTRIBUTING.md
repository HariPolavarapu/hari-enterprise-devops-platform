# Contributing to Enterprise DevOps Platform

Thank you for your interest in contributing! This document provides guidelines
for submitting issues, proposing changes, and ensuring your contributions meet
our quality and security standards.

## Code of Conduct

All contributors are expected to act professionally, respectfully, and
constructively. Harassment, discrimination, and toxic behavior will not be
tolerated.

## How to Contribute

### Reporting Bugs

1. Check [existing issues](../../issues) to avoid duplicates.
2. Open a new issue using the **Bug Report** template.
3. Provide a clear title, reproduction steps, expected vs. actual behavior, and
   environment details (OS, Docker version, Terraform version, etc.).

### Proposing Features

1. Open a **Feature Request** issue describing the use case, proposed solution,
   and alternatives considered.
2. Wait for maintainer feedback before investing significant implementation time.

### Pull Requests

1. **Fork** the repository and create a feature branch from the default branch.
2. **Make your changes** following the style guides below.
3. **Run local validation** (`make validate` and `make test`).
4. **Sign your commits** with `git commit -s` (Developer Certificate of Origin).
5. **Open a Pull Request** using the PR template.
6. Ensure all CI checks pass and requested reviewers approve.

## Developer Certificate of Origin (DCO)

By contributing to this project, you agree that your contributions are licensed
under the [Apache License 2.0](LICENSE) and you certify the following:

```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

All commits must include a `Signed-off-by` line. Use:

```bash
git commit -s -m "Your commit message"
```

## Style Guides

### Terraform

- Format with `terraform fmt` before submitting.
- Use descriptive variable and resource names.
- Document all variables in `variables.tf` with `description`.
- Keep modules focused and reusable.

### Ansible

- YAML indentation: 2 spaces.
- Use fully qualified collection names (FQCN) for modules.
- Idempotency is required — playbooks must be safe to run multiple times.

### Java (Spring Boot)

- Follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html).
- Run `mvn spotless:apply` if configured.
- Unit tests are required for new business logic.

### Python

- [PEP 8](https://peps.python.org/pep-0008/) compliant.
- Run `black` and `flake8` before committing.
- Type hints are encouraged for public APIs.

### TypeScript / Angular

- [Angular Style Guide](https://angular.io/guide/styleguide).
- Run `ng lint` and `ng test` before submitting.
- Prefer standalone components.

### Shell Scripts

- Use `#!/usr/bin/env bash` with `set -euo pipefail`.
- Quote all variables. Avoid backticks; use `$()` instead.
- Document functions with comments.

### Helm Charts

- Follow [Helm Best Practices](https://helm.sh/docs/chart_best_practices/).
- Lint with `helm lint`.
- Document all values in `values.yaml` with comments.

## Security Requirements

- **Never commit secrets, passwords, API keys, or personal credentials.**
- Use environment variables, secret managers, or encrypted files (SOPS, Vault)
  for sensitive data.
- Run `make validate` and `pre-commit run --all-files` before opening a PR.
- If your change affects infrastructure, security policies, or CI/CD, expect
  additional review from the designated CODEOWNERS teams.

## Review Process

- All PRs require at least **one approval** from a CODEOWNER.
- PRs affecting `security/`, `infrastructure/terraform/`, or `.github/workflows/`
  require approval from the respective specialist team.
- Automated checks (lint, test, container scan) must pass before merge.
- Maintainers may request changes or close PRs that do not meet standards.

## Questions?

If you have questions not covered here, open a **Discussion** or reach out via
the security contact in [SECURITY.md](SECURITY.md).

---

*Thank you for helping make the Enterprise DevOps Platform secure and reliable!*
