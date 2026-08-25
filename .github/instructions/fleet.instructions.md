---
applyTo: "**"
---
# Fleet conventions

Each `accounts/<identity>/` directory composes one restricted OpenStack account
through KRO instances. Use `SpokeIdentity`; keep provider restrictions in the
account's `ImmutableSpokeConfig`; keep mutable worker bounds in
`SpokeCluster`; deliver workloads with namespaced workload graph instances.
Use only the approved general worker flavor from account configuration. Do not
add GPU, high-memory, or per-cluster worker-class fields.

The `csoc/` directory contains trusted CSOC-local graph instances. It does not
contain an OpenStack account identity or spoke infrastructure.

Do not add credentials, secret references, raw CAPI resources, Argo
Applications, ApplicationSets, app assignments, or registration labels.
Hello workload Services must remain internal-only. Validate both
`kubectl kustomize .` and `kubectl kustomize accounts` before merging.
