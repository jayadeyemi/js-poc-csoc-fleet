# js-poc-csoc-fleet

Authoritative inventory of KRO graph instances for the CSOC POC.

## Layout

```
kustomization.yaml          root Kustomize entrypoint
csoc/
  hello-app.yaml            HelloApp with target: csoc
accounts/
  kustomization.yaml        active account list; empty means no spokes
  <identity>/
    identity-config.yaml    ImmutableSpokeConfig — trusted service blocks
    identity.yaml           SpokeIdentity — account namespace and OpenStackClusterIdentity
    spoke-config.yaml       SpokeEnvironmentConfig — network and cluster connection blocks
    network.yaml            exactly one selected network graph instance
    cluster.yaml            SpokeCluster — worker bounds only
    hello-app.yaml          HelloApp — CAPI addon workload instance
    kustomization.yaml
examples/accounts/<identity>/
                            inactive templates, network variants, and optional
                            compute/security/storage service graphs
```

`accounts/test-poc` is active only in the development CSOC profile and defines
the small `poc-tenant-dev` spoke. Production omits the fleet Application
entirely. Additional activation requires copying reviewed files into
`accounts/<identity>`, naming the selected network manifest `network.yaml`, and
listing that directory in `accounts/kustomization.yaml`. The Magnum credential
never belongs here.

## Rules

- Every spoke account uses `SpokeIdentity`, never `CSOCIdentity`.
- Credentials, secret names, and application-credential values never enter Git.
- Reviewed OpenStack project and provider IDs belong only in
  `identity-config.yaml` or the optional exact-ID `network-import-config.yaml`;
  consuming network/cluster graphs cannot override them.
- Mutable `minNodes` and `maxNodes` belong only in `cluster.yaml`. Spokes use the approved general worker flavor from `identity-config.yaml`; do not add GPU, high-memory, or per-cluster worker-class fields.
- Workloads use KRO/CAPI addon graphs only — no app assignments, registration labels, Argo Applications, or ApplicationSets.
- Hello Services are internal OpenStack load balancers. Do not add a floating IP or reuse the Kubernetes API load balancer.
- Removing manifests is the Git retirement gate but does not itself delete
  them because Argo pruning is disabled. Merge the removal, wait for Argo
  `Synced`, then use bootstrap's ownership-gated destroy-spoke operation.
- `kubectl kustomize accounts` and `make validate` must pass before merging.
