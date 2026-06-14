#!/usr/bin/env bash
set -euo pipefail
if [[ "${CONFIRM_DESTROY:-}" != "destroy" ]]; then
  echo "Set CONFIRM_DESTROY=destroy to continue." >&2
  exit 1
fi
terraform destroy
