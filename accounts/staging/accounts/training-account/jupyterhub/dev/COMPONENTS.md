# Training account JupyterHub dev components

## Declared and statically accepted

| Layer | Component | Owner |
| --- | --- | --- |
| Identity | `ImmutableSpokeConfig`, `SpokeIdentity`, restricted account runtime | CSOC/KRO; secret remains outside Git |
| Network | Dedicated Neutron network, subnet, shared-router interface | `DedicatedSpokeNetwork` / ORC |
| Access | ORC-managed Nova keypair from the reviewed public key | `SpokeKeypair` / ORC |
| Kubernetes | One control plane, autoscaled `1..2` workers, API load balancer | `SpokeCluster` / CAPI/CAPO |
| Addons | Calico, OpenStack CCM, Cinder CSI, namespace-scoped Cluster Autoscaler | `SpokeCluster` addons |
| GitOps | Pinned spoke Argo CD and one pinned root Application | `SpokeArgoCD`, `SpokeArgoApplication` |
| Application | Minimal JupyterHub dev chart, internal Octavia Service | GitOps fork |
| Data | Retained 10-GiB Hub DB and dynamic retained user PVCs | JupyterHub over Cinder CSI |

Availability and deployment gates are maintained in the workspace-root
`STAGING-APPLICATION-AVAILABILITY.md` report.

No manifest in this package authorizes substituting components, exposing the
application publicly, deleting retained PVCs, or adopting the legacy
`js2-mgmt-cluster-2` management cluster.
