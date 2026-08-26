# Retired `poc-tenant-dev` composition

This directory records the complete fleet composition removed from `accounts/`
on 2026-08-26. Moving it here is the reviewed Git retirement signal. It is not
rendered by the root kustomization and therefore cannot recreate the spoke.

The composition used a KRO-managed network and subnet attached to the existing
Jetstream2 allocation router, an ORC-managed keypair, a CAPI/CAPO cluster with
one control plane and `1..2` workers, and a CSOC-managed Hello workload delivered
through a `ClusterResourceSet`.

To reuse it, first change every identity, namespace, cluster name, CIDR, public
key, access CIDR, and reviewed OpenStack UUID. Copy the reviewed directory under
`accounts/<identity>/`, then add that directory to `accounts/kustomization.yaml`.
Never reactivate this exact identity or adopt any retained OpenStack object by
name.

Removing an active composition from Git does not delete it because fleet Argo
pruning is disabled. After the removal is merged and `csoc-fleet` is Synced to
that revision, use bootstrap's ownership-gated `destroy-spoke` operation.
