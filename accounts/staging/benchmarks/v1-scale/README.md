# Staging v1 scale benchmark

This inventory measures real OpenStack convergence for one v1 `SpokeCluster`
and then ten independently owned v1 spokes enqueued together. The ordinary
`accounts/staging/kustomization.yaml` deliberately excludes every
`scale-*` tuple. Each tuple is reached only through its manual
`csoc-v1-scale-NN` Argo Application.

Every account uses a different restricted 90-day application credential in the
same project. This exercises namespace and credential-cache isolation without
claiming real OpenStack project separation.

Run from the staging management container after controller/RGD acceptance and
credential loading:

```bash
bash scripts/operations/benchmarks/run-v1-scale.sh --phase single
bash scripts/operations/benchmarks/run-v1-scale.sh --phase batch
```

The runner records T0 immediately before the Argo sync request. Its primary
completion point requires the expected Nova servers, Neutron networks/subnets,
Octavia load balancers, and Cinder roots to be ready; Kubernetes and KRO
readiness are recorded separately. Evidence is written beneath ignored
`.state/benchmarks/v1-scale/<timestamp>-<phase>/`.

Before T0 it runs the read-only credential, ownership, collision, CIDR, and
quota gate. After convergence it compares exact before/after IDs and rejects
any unexplained server, network, subnet, load-balancer, volume, or deletion.

A timeout captures diagnostics and exits without deleting or resubmitting
anything. All eleven spokes remain staging-owned after a successful run.
