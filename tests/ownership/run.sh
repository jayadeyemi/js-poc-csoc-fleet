#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="${SCRIPT_DIR}/../../scripts/validate-ownership.sh"

bash "${VALIDATOR}" "${SCRIPT_DIR}/valid.yaml" >/dev/null
for fixture in "${SCRIPT_DIR}"/reject-*.yaml; do
  if bash "${VALIDATOR}" "${fixture}" >/dev/null 2>&1; then
    echo "expected rejection: ${fixture}" >&2
    exit 1
  fi
done
echo "ownership fixture tests passed"
