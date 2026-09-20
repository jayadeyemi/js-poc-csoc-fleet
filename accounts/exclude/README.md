# Excluded fleet instances

This tree stores complete fleet-instance examples that no environment owner
Kustomization renders. The staging Argo CD fleet Application points at
`accounts/staging`, so it cannot discover this sibling tree. The empty
`accounts/exclude/kustomization.yaml` is an additional fail-closed boundary if
an operator targets the exclusion root by mistake.

Excluded instances are documentation and recovery inputs, not desired live
state. Moving a tuple here does not delete its Kubernetes or OpenStack
resources: every infrastructure Application has pruning disabled. Retire live
resources only through the reviewed, ownership-gated destroy workflow after
backup and exact-resource verification.

