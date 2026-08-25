# js-poc-csoc-fleet

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

`accounts/test-poc` is the active development account and produces the small
`poc-tenant-dev` spoke. The production CSOC omits its fleet Application, so it
cannot render these instances. Reusable inactive variants remain under
`examples/accounts/test-poc`. The CSOC Magnum credential does not belong here.

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
- Workloads use KRO/CAPI addon graphs. Do not add app assignments, registration
  labels, Argo Applications, or ApplicationSets.
- Hello application Services are internal OpenStack load balancers. Do not add
  a floating IP, remove the internal-only annotation, or reuse the Kubernetes
  API load balancer without a separately reviewed restricted-access change.
- Removing a cluster/network manifest and merging it is the required retirement
  signal, but Argo pruning remains disabled. Live teardown uses bootstrap's
  explicit workload-first, CAPI-first, then network operation.
- `kubectl kustomize accounts` and the workspace validation gate must pass.
