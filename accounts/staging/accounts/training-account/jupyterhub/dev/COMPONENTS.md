# Training account JupyterHub dev components

Inventory date: 2026-08-27. Live values are read-only observations and must be
rechecked immediately before reconciliation.

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

## Live cloud availability

- Available: the approved Kubernetes image is active; the exact external
  network is external; Nova, Neutron, Cinder, and Octavia endpoints respond.
- Available headroom: 222 instances, 2,277 cores, 7,386,367 MiB RAM, 98
  networks, 98 subnets, 58 routers, 964 ports, 161 floating IPs, 280 security
  groups, 414 volumes, and 41,594 GiB of volume capacity.
- Unavailable: approved CPU flavors `m3.small` and `m3.quad`. The project
  currently lists only `g3.large`, `g3.medium`, `g3.xl`, and `g4.xl`; the CSOC
  policy forbids silently substituting a GPU flavor.
- Unavailable: Octavia quota headroom. Current usage is five load balancers
  above the reported project limit, while this composition needs an API load
  balancer and one separate internal application load balancer.

## Deployment gates

- `csoc-staging` has no ownership state or kubeconfig and therefore cannot
  reconcile this tuple yet.
- The staging Magnum credential observed before this change is invalid. A new
  short-lived unrestricted staging-only credential is required before an
  explicitly authorized `csoc-staging` create.
- The pinned config and GitOps fork commits are local until separately
  published. Argo CD cannot resolve them from GitHub before publication.
- ACCESS/CILogon, public DNS/TLS, Manila/CephFS, registry cache, BinderHub,
  monitoring, remote outposts, and GPU/MIG profiles remain unavailable for the
  reasons documented in the config fork's `projects/training-account/README.md`.

No manifest in this package authorizes substituting components, exposing the
application publicly, deleting retained PVCs, or adopting the legacy
`js2-mgmt-cluster-2` management cluster.
