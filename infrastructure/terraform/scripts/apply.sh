#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-dev}"
cd "$(dirname "$0")/../environments/${ENV}"
terraform apply -var-file=terraform.tfvars
