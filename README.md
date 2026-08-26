# js-poc-csoc-fleet

Authoritative inventory of KRO graph instances for the CSOC POC.

## Layout

```
kustomization.yaml          root Kustomize entrypoint
csoc/
  hello-app.yaml            direct CSOC-local HelloApp
accounts/
  kustomization.yaml        active account list; currently empty
  <identity>/               reviewed active graph instances only
examples/
  compositions/            complete topology and storage choices
  connections/             central and spoke-local GitOps delivery modes
  workload-repositories/    sample repo content for spoke-local Argo
  retired/                  inactive records of retired compositions
```

No spoke is currently active. The former `poc-tenant-dev` composition is kept
under `examples/retired/`. Production omits the fleet Application entirely.
Activation starts from one documented composition under `examples/`; the
Magnum credential never belongs here.

## Rules

- Every spoke account uses `SpokeIdentity`, never `CSOCIdentity`.
- Credentials, secret names, and application-credential values never enter Git.
- Reviewed OpenStack project and provider IDs belong only in
  `identity-config.yaml` or the optional exact-ID `network-import-config.yaml`;
  consuming network/cluster graphs cannot override them.
- Mutable `minNodes` and `maxNodes` belong only in `cluster.yaml`. Spokes use the approved general worker flavor from `identity-config.yaml`; do not add GPU, high-memory, or per-cluster worker-class fields.
- `HelloApp` is CSOC-local. `SpokeHelloApp` is delivered centrally through a
  CAPI `ClusterResourceSet`. `SpokeGitOps` installs spoke-local Argo CD and a
  root Application for a public repository. Do not give one workload two owners.
- CSOC Hello uses an internal load balancer. Centrally delivered spoke Hello
  uses a separate source-restricted public load balancer and never reuses the
  Kubernetes API load balancer.
- Removing manifests is the Git retirement gate but does not itself delete
  them because Argo pruning is disabled. Merge the removal, wait for Argo
  `Synced`, then use bootstrap's ownership-gated destroy-spoke operation.
- `kubectl kustomize accounts` and `make validate` must pass before merging.

See [`examples/README.md`](examples/README.md) for the composition matrix and
exact add/remove semantics.
