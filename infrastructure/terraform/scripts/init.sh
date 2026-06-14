#!/usr/bin/env bash
set -euo pipefail
terraform init -backend-config="${1:-backend.hcl}"
