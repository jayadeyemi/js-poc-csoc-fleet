#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="${SCRIPT_DIR}/../../scripts/validate-v2-capacity.sh"

bash "${VALIDATOR}" "${SCRIPT_DIR}/valid.yaml" >/dev/null
bash "${VALIDATOR}" "${SCRIPT_DIR}/valid.yaml" "${SCRIPT_DIR}/live-valid.json" >/dev/null
if bash "${VALIDATOR}" "${SCRIPT_DIR}/reject-budget.yaml" >/dev/null 2>&1; then
  echo "expected undersized capacity budget rejection" >&2
  exit 1
fi
if bash "${VALIDATOR}" "${SCRIPT_DIR}/valid.yaml" "${SCRIPT_DIR}/live-reject.json" >/dev/null 2>&1; then
  echo "expected insufficient live quota rejection" >&2
  exit 1
fi
echo "capacity fixture tests passed"
