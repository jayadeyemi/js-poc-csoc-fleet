#!/usr/bin/env bash
# Static validation for reusable v2 clusters and application tuple ownership.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REGISTRY="${1:-${REPO_ROOT}/ownership.yaml}"

for command_name in jq yq; do
  command -v "${command_name}" >/dev/null 2>&1 || {
    echo "missing required command: ${command_name}" >&2
    exit 1
  }
done

registry_json=$(yq -o=json '.' "${REGISTRY}")
jq -e '
  . as $root |
  .apiVersion == "fleet.csoc.js2.org/v1alpha1" and
  .kind == "FleetOwnershipRegistry" and
  (.clusters | type == "array" and length > 0) and
  (.applications | type == "array" and length > 0) and
  ([.clusters[].name] | length == (unique | length)) and
  ([.clusters[] | [.account, .owner, .type, .path] | all(. != null and . != "")] | all) and
  ([.clusters[].owner | . == "staging" or . == "prod"] | all) and
  ([.clusters[].type | . == "WorkloadCluster"] | all) and
  ([.applications[] | [.account, .app, .environment, .owner, .type, .clusterRef, .path] | all(. != null and . != "")] | all) and
  ([.applications[].type | IN("SmokeApplication", "JupyterHubInstance", "MonitoringInstance", "RegistryCacheInstance", "BinderBuildInstance", "JupyterOutpostInstance")] | all) and
  ([.applications | group_by([.account, .app, .environment])[] | length == 1] | all) and
  ([$root.applications[] as $app |
      ($root.clusters[] | select(.name == $app.clusterRef)) as $cluster |
      ($cluster.owner == $app.owner and $cluster.account == $app.account)] |
      length == ($root.applications | length) and all)
' <<<"${registry_json}" >/dev/null || {
  echo "invalid v2 fleet ownership registry: ${REGISTRY}" >&2
  exit 1
}

while IFS= read -r declared_path; do
  [[ -e "${REPO_ROOT}/${declared_path}" ]] || {
    echo "ownership path does not exist: ${declared_path}" >&2
    exit 1
  }
done < <(jq -r '(.clusters[]?.path), (.applications[]?.path), (.legacyAssignments[]?.path)' <<<"${registry_json}")

if [[ "${REGISTRY}" == "${REPO_ROOT}/ownership.yaml" ]]; then
  [[ $(yq -o=json '.' "${REPO_ROOT}/environments/dev/kustomization.yaml" | jq '.resources | length') == 0 ]] || {
    echo "development fleet must render no instances" >&2
    exit 1
  }
fi

echo "v2 ownership registry valid: ${REGISTRY}"
