# js-poc-csoc-fleet

## Environment and ownership invariants

- Argo renders only `environments/<owner>`. `environments/dev` is always empty.
- Active instances use `accounts/<account>/<app>/<environment>` below their
  owner root and canonical name `<account>-<app>-<environment>`.
- Every tuple appears exactly once in `ownership.yaml`; staging initially owns
  only `test-poc/hello-app/dev`. Prod owns prod and explicitly routed dev tuples.
- Tuple labels, identity name, namespace, cluster name, and app reference must
  agree. A duplicate tuple or name is a validation failure.
- Argo pruning stays disabled for infrastructure. Removing Git does not delete
  a spoke; retirement is an exact-name/UUID reviewed workflow after backups.
- Keep dev instances minimal, use dedicated Cinder PVCs for persistent data,
  and prove reconciliation preserves those PVCs before promotion.
- V2 fleet instances create management-side KRO/CAPI/Argo control objects only.
  Every addon, policy, PVC, monitoring component, and application must be an
  Argo destination in the spoke cluster. Do not add v2 CAPI addon delivery.
- Never specify `MachineDeployment.spec.replicas` through a `SpokeNodePool`;
  its min/max annotations are the bounds and Cluster Autoscaler owns replicas.
- Declare account capacity from pool maxima and retained claim maxima, then
  validate it against live OpenStack quota before an active fleet commit.
- Optional v2 GPU/MIG, CephFS, S3, Binder, and Outpost instances are forbidden;
  registry cache may render in tests but is not active in the first rollout.

This repository is the authoritative inventory of KRO graph instances.

```
csoc/
  hello-app.yaml          CSOC-local direct workload instance
accounts/
  kustomization.yaml
  <identity>/
    identity-config.yaml  ImmutableSpokeConfig
    identity.yaml         SpokeIdentity
    spoke-config.yaml     SpokeEnvironmentConfig
    network.yaml          network graph instance
    cluster.yaml          SpokeCluster
    hello-app.yaml        direct CAPI addon workload instance
    kustomization.yaml
```

No spoke account is currently active. The retired `poc-tenant-dev` composition
is preserved under `examples/retired/`, and reusable complete variants live
under `examples/compositions/`. The production CSOC omits its fleet
Application, so it cannot render these instances. The CSOC Magnum credential
does not belong here.

## Rules

- Every spoke account uses `SpokeIdentity`, never `CSOCIdentity`.
- Keep all instances for an account together under `accounts/<identity>`.
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
- `kubectl kustomize accounts` and the workspace validation gate must pass.
