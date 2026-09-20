# Retired staging v1 scale source paths

The complete `scale-00` through `scale-10` examples moved to
`accounts/exclude/staging/v1-scale/accounts/`. The manual Argo Applications
still target their original paths during the retirement transition. Each
original path contains an empty Kustomization, so Argo can compare it without
rendering desired graph instances.

Because those Applications do not enable pruning, a refresh or sync reports
the live graph instances as extraneous but does not delete them or their
OpenStack infrastructure. Remove the live Applications and infrastructure only
through the separately approved retirement workflow.
