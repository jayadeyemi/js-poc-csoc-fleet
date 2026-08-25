# test-poc

No resources in this directory are active. The former `poc-tenant-dev` spoke
was removed from desired state before its controller-led teardown.

To provision this account again, copy the reviewed files from
`examples/accounts/test-poc/` into this directory, replace every documented
placeholder, add `test-poc` to `accounts/kustomization.yaml`, load the separate
restricted account credential, and follow the first-install ordering in the
bootstrap repository. Do not restore `cluster.yaml` until its identity,
configuration blocks, and selected network graph are Ready.
