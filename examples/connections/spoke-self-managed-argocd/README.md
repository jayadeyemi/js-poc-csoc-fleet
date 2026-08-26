# Spoke-local Argo CD connection

This mode uses `SpokeGitOps`. KRO creates a `HelmChartProxy` in the CSOC cluster;
the CAPI addon provider installs Argo CD into the selected spoke and creates a
spoke-local root `Application`. That Argo instance then pulls the configured
public repository and reconciles resources against its own cluster.

The example points to this repository's `examples/workload-repositories/hello`
path. Copy `spoke-gitops.yaml` into an active account after its cluster exists,
then change `repositoryURL`, revision, path, and destination namespace. A
private repository additionally requires a separately designed spoke-local
repository credential Secret; never put it in this instance or in Git.

Do not combine this with `SpokeHelloApp` for the same workload. Choose one
owner. Remove the root application/workloads first, then delete `SpokeGitOps`
to uninstall spoke Argo before retiring the cluster.
