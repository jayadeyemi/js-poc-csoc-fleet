# js-poc-csoc-fleet

This repository is the authoritative inventory of KRO graph instances.

```
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

The initial account is `accounts/test-poc`. The CSOC Magnum credential does
not belong here. The ignored runtime credential is loaded separately from
`js-poc-csoc-bootstrap/scripts/host/credentials/accounts/test-poc/clouds.yaml`.

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
- Removing a cluster or network manifest does not authorize deletion; live
  teardown remains an explicit CAPI-first operation.
- `kubectl kustomize accounts` and the workspace validation gate must pass.
