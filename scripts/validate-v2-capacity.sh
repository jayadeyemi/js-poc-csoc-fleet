#!/usr/bin/env bash
# Validate the maximum declared v2 topology against its account capacity budget.
set -euo pipefail

SOURCE=${1:?usage: validate-v2-capacity.sh RENDERED-YAML [LIVE-QUOTA-JSON]}
LIVE_QUOTA=${2:-}

for command_name in jq yq; do
  command -v "${command_name}" >/dev/null 2>&1 || {
    echo "missing required command: ${command_name}" >&2
    exit 1
  }
done

documents=$(yq eval-all -o=json '[.]' "${SOURCE}")
jq -e '
  def named($all; $kind; $ns; $name):
    first($all[] | select(.kind == $kind and .metadata.namespace == $ns and .metadata.name == $name));
  def profile_cost($profile; $count):
    {cores: ($profile.spec.vCPUs * $count), ramMiB: ($profile.spec.ramMiB * $count), instances: $count, volumes: $count, volumeGiB: (($profile.spec.rootSizeGiB // 20) * $count)};
  def plus($a; $b):
    {cores: ($a.cores + $b.cores), ramMiB: ($a.ramMiB + $b.ramMiB), instances: ($a.instances + $b.instances), volumes: ($a.volumes + $b.volumes), volumeGiB: ($a.volumeGiB + $b.volumeGiB)};
  . as $all |
  [.[] | select(.kind == "SpokeAccount") | . as $account |
    .metadata.namespace as $ns |
    ([ $all[] | select(.kind == "MachineProfile" and .metadata.namespace == $ns and .spec.accountRef.name == $account.metadata.name) ] | length) as $profileCount |
    ([ $all[] | select(.kind == "WorkloadCluster" and .metadata.namespace == $ns and .spec.accountRef.name == $account.metadata.name) ] | length) as $clusterCount |
    ([ $all[] | select(.kind == "SpokeNodePool" and .metadata.namespace == $ns) ] | length) as $poolCount |
    ([ $all[] | select(.kind == "WorkloadCluster" and .metadata.namespace == $ns and .spec.accountRef.name == $account.metadata.name) |
       . as $cluster | profile_cost(named($all; "MachineProfile"; $ns; $cluster.spec.controlPlaneProfileRef.name); $cluster.spec.controlPlaneCount) ] |
       reduce .[] as $cost ({cores:0,ramMiB:0,instances:0,volumes:0,volumeGiB:0}; plus(.; $cost))) as $controlPlane |
    ([ $all[] | select(.kind == "SpokeNodePool" and .metadata.namespace == $ns) |
       . as $pool | profile_cost(named($all; "MachineProfile"; $ns; $pool.spec.profileRef.name); $pool.spec.maxNodes) ] |
       reduce .[] as $cost ({cores:0,ramMiB:0,instances:0,volumes:0,volumeGiB:0}; plus(.; $cost))) as $workers |
    ([ $all[] | select(.kind == "CinderStorageBinding" and .metadata.namespace == $ns) | .spec.maxClaims ] | add // 0) as $retainedClaims |
    ([ $all[] | select(.kind == "CinderStorageBinding" and .metadata.namespace == $ns) | (.spec.maxClaims * .spec.sizeGiB) ] | add // 0) as $retainedGiB |
    plus($controlPlane; $workers) as $compute |
    ($compute + {volumes: ($compute.volumes + $retainedClaims), volumeGiB: ($compute.volumeGiB + $retainedGiB)}) as $required |
    {
      account: $account.metadata.name,
      valid:
        ($profileCount <= $account.spec.controlObjectBudget.maxMachineProfiles and
         $clusterCount <= $account.spec.controlObjectBudget.maxWorkloadClusters and
         $poolCount <= $account.spec.controlObjectBudget.maxNodePools and
         $required.cores <= $account.spec.capacityBudget.maxCores and
         $required.ramMiB <= $account.spec.capacityBudget.maxRAMMiB and
         $required.instances <= $account.spec.capacityBudget.maxInstances and
         $required.volumes <= $account.spec.capacityBudget.maxVolumes and
         $required.volumeGiB <= $account.spec.capacityBudget.maxVolumeGiB),
      required: $required,
      declared: $account.spec.capacityBudget,
      objects: {machineProfiles:$profileCount, workloadClusters:$clusterCount, nodePools:$poolCount}
    }
  ] | length > 0 and all(.valid)
' <<<"${documents}" >/dev/null || {
  echo "declared v2 topology exceeds its account capacity budget: ${SOURCE}" >&2
  exit 1
}

if [[ -n "${LIVE_QUOTA}" ]]; then
  jq -e --argjson documents "${documents}" '
    def requirement:
      $documents as $all |
      [ $all[] | select(.kind == "SpokeAccount") | .spec.capacityBudget ] |
      {
        cores: (map(.maxCores) | add // 0),
        ramMiB: (map(.maxRAMMiB) | add // 0),
        instances: (map(.maxInstances) | add // 0),
        volumes: (map(.maxVolumes) | add // 0),
        volumeGiB: (map(.maxVolumeGiB) | add // 0)
      };
    requirement as $required |
    (.compute.cores.limit - .compute.cores.in_use) >= $required.cores and
    (.compute.ramMiB.limit - .compute.ramMiB.in_use) >= $required.ramMiB and
    (.compute.instances.limit - .compute.instances.in_use) >= $required.instances and
    (.volume.volumes.limit - .volume.volumes.in_use) >= $required.volumes and
    (.volume.gigabytes.limit - .volume.gigabytes.in_use) >= $required.volumeGiB
  ' "${LIVE_QUOTA}" >/dev/null || {
    echo "live OpenStack quota does not cover the declared capacity budget" >&2
    exit 1
  }
fi

echo "v2 account capacity budget valid: ${SOURCE}"
