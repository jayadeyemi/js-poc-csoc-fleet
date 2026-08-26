# CSOC-managed workload connection

This mode keeps Argo CD and KRO in the CSOC management cluster. Argo reconciles
the `SpokeHelloApp` instance; KRO creates a CAPI `ClusterResourceSet`; CAPI
applies the rendered Namespace, ConfigMap, Deployment, and Service to the spoke.
The spoke does not run Argo CD and is not registered as a direct Argo target.

Copy `spoke-hello.yaml` into the active account after the matching
`SpokeCluster` and network connection exist, then list it after the cluster in
that account's kustomization. Set the exact cluster name and a reviewed `/32`
source CIDR. To remove it, merge removal intent and explicitly delete the
`SpokeHelloApp` before retiring the cluster so its load balancer is cleaned up
while the spoke API is reachable.
