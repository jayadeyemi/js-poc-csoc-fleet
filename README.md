# js-poc-csoc-fleet

Authoritative inventory of KRO graph instances for the CSOC POC.

## Layout

```
kustomization.yaml          intentionally empty safety root
ownership.yaml              unique tuple-to-CSOC assignments
accounts/
  dev/                      always empty; graph development creates no instances
  staging/accounts/<account>/<app>/<environment>/
                             staging-owned dev instances
  prod/accounts/<account>/<app>/<environment>/
                             prod and explicitly routed dev instances
examples/
  compositions/            complete topology and storage choices
  connections/             central and spoke-local GitOps delivery modes
  workload-repositories/    sample repo content for spoke-local Argo
  retired/                  inactive records of retired compositions
```

The compatibility tuple is `test-poc/hello-app/dev`, and the first reference
adaptation is `training-account/jupyterhub/dev`; both are owned by staging and
use canonical tuple names. The former `poc-tenant-dev` composition remains under
`examples/retired/` for compatibility comparison. The Magnum credential never
belongs here.

## Rules

- Every spoke account uses `SpokeIdentity`, never `CSOCIdentity`.
- Credentials, secret names, and application-credential values never enter Git.
- Reviewed OpenStack project and provider IDs belong only in
  `identity-config.yaml` or the optional exact-ID `network-import-config.yaml`;
  consuming network/cluster graphs cannot override them.
- Mutable `minNodes` and `maxNodes` belong only in `cluster.yaml`. Spokes use the approved general worker flavor from `identity-config.yaml`; do not add GPU, high-memory, or per-cluster worker-class fields.
- Do not create CSOC-local application instances. `SpokeHelloApp` is delivered through a
  CAPI `ClusterResourceSet`. `SpokeGitOps` installs spoke-local Argo CD and a
  root Application for a public repository. Do not give one workload two owners.
- CSOC Hello uses an internal load balancer. Centrally delivered spoke Hello
  uses a separate source-restricted public load balancer and never reuses the
  Kubernetes API load balancer.
- Removing manifests is the Git retirement gate but does not itself delete
  them because Argo pruning is disabled. Merge the removal, wait for Argo
  `Synced`, then use bootstrap's ownership-gated destroy-spoke operation.
- Render every owner root and run bootstrap `make validate` before merging.

See [`examples/README.md`](examples/README.md) for the composition matrix and
exact add/remove semantics.
