#!/usr/bin/env bash
set -euo pipefail
terraform fmt -recursive "$(dirname "$0")/.."
