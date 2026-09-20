# Staging v1 scale benchmark

This package preserves the complete manifests and inventory used to measure
real OpenStack convergence for one v1 `SpokeCluster` and then ten independently
owned v1 spokes enqueued together. It is inactive: the staging fleet
Application points at `accounts/staging`, while this package is below the
sibling `accounts/exclude` safety boundary.

Every account uses a different restricted 90-day application credential in the
same project. This exercises namespace and credential-cache isolation without
claiming real OpenStack project separation.

The historical benchmark runner remains useful for reading retained evidence,
but do not run a new phase or point an Argo Application at this package without
new provisioning authorization. The previous commands were:

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
anything. The eleven tuple names remain reserved to staging in the root
ownership registry so another owner cannot reuse them.

`kubectl kustomize accounts/exclude/staging/v1-scale` statically renders all
eleven complete six-resource examples. Rendering is safe; applying that output
would provision infrastructure and remains explicitly gated.
