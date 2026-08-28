# js-poc-csoc-fleet

Authoritative inventory of KRO graph instances for the CSOC POC.

## Layout

```
kustomization.yaml          intentionally empty safety root
ownership.yaml              unique tuple-to-CSOC assignments
environments/
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

The initial v2 candidate tuple is `test-poc/hello-app/dev`, owned by staging on
shared cluster `test-poc-v2-dev`. The former `poc-tenant-dev` composition remains under
`examples/retired/` for compatibility comparison. The Magnum credential never
belongs here.

`ownership.yaml` now has separate `clusters` and `applications` collections.
An application entry must declare its typed service Kind and `clusterRef`; the
validator requires the referenced cluster to exist and have the same account
and owning CSOC. `legacyAssignments` records only compatibility instances and
is excluded from the v2 graph. The staging package is promoted only after dev
accepts its exact OpenStack IDs and source commits.

## Rules

- Every spoke account uses `SpokeIdentity`, never `CSOCIdentity`.
- Credentials, secret names, and application-credential values never enter Git.
- Reviewed OpenStack project and provider IDs belong only in
  `identity-config.yaml` or the optional exact-ID `network-import-config.yaml`;
  consuming network/cluster graphs cannot override them.
- In v2, mutable `minNodes` and `maxNodes` belong only to independent
  `SpokeNodePool` instances. Machine class, flavor/image/volume IDs, and
  placement come from immutable `MachineProfile` instances. The older
  single-worker restriction applies only to `legacyAssignments`. Do not set a
  `MachineDeployment` replica count in v2; CAPI initializes from the minimum
  annotation and the spoke-local autoscaler owns it afterward.
- V2 instances live in CSOC, but their Argo Applications target the registered
  spoke. Addons, storage, policies, monitoring, and applications must render
  only in the spoke cluster; CAPI/CAPO/ORC and Argo control objects remain in
  CSOC. `ClusterResourceSet`/`HelmChartProxy` and spoke-local Argo are
  compatibility-only paths.
- CSOC Hello uses an internal load balancer. Centrally delivered spoke Hello
  uses a separate source-restricted public load balancer and never reuses the
  Kubernetes API load balancer.
- Removing manifests is the Git retirement gate but does not itself delete
  them because Argo pruning is disabled. Merge the removal, wait for Argo
  `Synced`, then use bootstrap's ownership-gated destroy-spoke operation.
- Render every environment and run bootstrap `make validate` before merging.
- Size `SpokeAccount.capacityBudget` from control-plane counts, every pool
  maximum, profile vCPU/RAM, boot-volume count/GiB, and retained claim count/GiB. Run
  `scripts/validate-v2-capacity.sh` statically and against a freshly captured
  live quota document before activation.
- The first shared staging target is control plane `1`, system `1..1`, and CPU
  `0..1`; every root is 20 GiB. JupyterHub uses 1-GiB retained hub DB and
  10-GiB dynamic retained homes; monitoring uses 20-GiB retained Prometheus.
- Rotation changes only `SpokeRegistration.spec.rotationRequest`. Retirement
  removes application references first and never removes a finalizer while the
  spoke is unreachable.

See [`examples/README.md`](examples/README.md) for the composition matrix and
exact add/remove semantics.
