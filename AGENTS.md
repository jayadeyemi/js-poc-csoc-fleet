# js-poc-csoc-fleet

## Environment and ownership invariants

- Argo renders only `accounts/<owner>`. `accounts/dev` is always empty.
- Active instances use `accounts/<account>/<app>/<environment>` below their
  owner root and canonical name `<account>-<app>-<environment>`.
- Every tuple appears exactly once in `ownership.yaml`. Staging owns its
  ordinary dev tuples and reserves the excluded `scale-00..10/kubernetes/dev`
  benchmark; prod owns production and explicitly routed dev tuples.
- Complete but inactive fleet instances live only below `accounts/exclude`.
  Environment Kustomizations and active Argo source paths must not reference
  that tree.
- Tuple labels, identity name, namespace, cluster name, and app reference must
  agree. A duplicate tuple or name is a validation failure.
- Argo pruning stays disabled for infrastructure. Removing Git does not delete
  a spoke; retirement is an exact-name/UUID reviewed workflow after backups.
- Keep dev instances minimal, use dedicated Cinder PVCs for persistent data,
  and prove reconciliation preserves those PVCs before promotion.

This repository is the authoritative inventory of KRO graph instances.

```
csoc/
  hello-app.yaml          CSOC-local direct workload instance
accounts/
  <owner>/
    kustomization.yaml
    accounts/<account>/<app>/<environment>/
    identity-config.yaml  ImmutableSpokeConfig
    identity.yaml         SpokeIdentity
    spoke-config.yaml     SpokeEnvironmentConfig
    network.yaml          network graph instance
    cluster.yaml          SpokeCluster
    hello-app.yaml        optional direct CAPI addon workload instance
    kustomization.yaml
  exclude/                complete inactive examples; fail-closed root
```

Staging currently renders the ordinary tuples explicitly listed in
`accounts/staging/kustomization.yaml`. The scale benchmark is excluded from
desired state, the retired `poc-tenant-dev` composition is preserved under
`examples/retired/`, and reusable variants live under
`examples/compositions/`. The CSOC Magnum credential does not belong here.

## Rules

- Every spoke account uses `SpokeIdentity`, never `CSOCIdentity`.
- Keep active instances under
  `accounts/<owner>/accounts/<account>/<app>/<environment>`.
- Keep inactive instance examples under `accounts/exclude`; never add that
  directory to an environment Kustomization.
- Credentials, secret names, and application-credential values never enter Git.
- Reviewed OpenStack project/provider IDs belong only in
  `identity-config.yaml`; consuming network and cluster instances cannot
  override them.
- Mutable `minNodes` and `maxNodes` choices belong only in `cluster.yaml`.
  Spokes use the approved general worker flavor from `identity-config.yaml`;
  do not add GPU, high-memory, or per-cluster worker-class fields.
  Other write-once allocation values flow through graph-produced immutable
  ConfigMaps.
- CSOC-local workloads use `HelloApp`; centrally delivered spoke workloads use
  `SpokeHelloApp`; spoke-owned GitOps uses `SpokeGitOps`. Do not combine central
  and spoke-local ownership for the same workload.
- Hello application Services are internal OpenStack load balancers. Do not add
  a floating IP, remove the internal-only annotation, or reuse the Kubernetes
  API load balancer without a separately reviewed restricted-access change.
- Removing a cluster/network manifest and merging it is the required retirement
  signal, but Argo pruning remains disabled. Live teardown uses bootstrap's
  explicit workload-first, CAPI-first, then network operation.
- `kubectl kustomize accounts/<owner>` for every owner root and the workspace
  validation gate must pass.
