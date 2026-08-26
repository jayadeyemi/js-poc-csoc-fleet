# Sample spoke-owned repository path

This Kustomize package is the repository target used by the `SpokeGitOps`
example. It contains ordinary Kubernetes resources only. The spoke-local Argo
CD root Application points here and owns these objects directly.

In a real deployment, place workloads in a dedicated repository, pin a reviewed
revision or promotion branch, and add repository credentials out of band when
the repository is private.
