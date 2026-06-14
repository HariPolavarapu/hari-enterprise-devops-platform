#!/usr/bin/env bash
set -euo pipefail
test -f tfplan
terraform apply tfplan
