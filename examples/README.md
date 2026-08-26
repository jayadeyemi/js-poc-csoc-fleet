# Fleet composition examples

Every directory below is inactive and independently renderable. A composition
is a set of KRO graph **instances**; the RGD definitions remain in the app
catalog. Nothing under `examples/` is included by the fleet root.

| Composition | OpenStack network behavior | Cluster | Optional resources |
|---|---|---:|---|
| `compositions/dedicated-no-storage` | Creates network/subnet; attaches the reviewed allocation router | yes | keypair |
| `compositions/dedicated-with-storage` | Same as above | yes | keypair and Cinder volume |
| `compositions/attach-existing-network` | Imports exact network/subnet/router IDs; creates none | yes | keypair |
| `compositions/fully-managed-routed` | Creates network/subnet/router/interface | yes | keypair |
| `compositions/isolated-network-only` | Creates network/subnet without a router | no | none |
| `connections/csoc-managed-hello` | Uses the selected cluster network | existing cluster | CSOC-delivered Hello |
| `connections/spoke-self-managed-argocd` | Uses the selected cluster network | existing cluster | spoke-local Argo CD and root repo |

## Add a composition

1. Copy one composition to `accounts/<new-identity>/`.
2. Replace every example identity, namespace, resource name, CIDR, project ID,
   image ID, public key, access CIDR, and imported resource UUID.
3. Create the restricted runtime credential outside Git and load it with the
   bootstrap credential helper.
4. Keep exactly one network graph instance. Every `SpokeCluster` needs the
   `<cluster>-connection` ConfigMap produced by that graph.
5. Add `<new-identity>` to `accounts/kustomization.yaml`; Argo then reconciles
   the graph instances in sync-wave order.

## Add or remove one graph instance

To add storage, copy a `SpokeVolume` document into the active account and list
it in that account's kustomization. It creates an independent Cinder volume; it
does not create a Kubernetes PVC or attach itself to a server. To remove it,
first remove it from Git and merge that intent, then explicitly delete the
instance only after deciding whether its Cinder volume may be deleted.

The same rule applies to `SpokeSecurityGroup` and `SpokeServerGroup`: these are
independent service resources, not implicit inputs to `SpokeCluster`. Adding
one does not silently attach it to a machine.

Never switch network graphs in place. Retire the workload and CAPI cluster,
delete the old network owner through the reviewed operation, then activate the
replacement network graph. Immutable connection ConfigMaps deliberately block
in-place topology adoption.

## Remove a cluster

Removing an account from `accounts/kustomization.yaml` is the Git retirement
signal, not the deletion operation. Fleet Argo pruning is intentionally off.
Merge the removal, wait for `csoc-fleet` to report Synced at that revision, and
run bootstrap's exact-name, exact-ownership `destroy-spoke` operation. It
removes workload resources first, CAPI second, and KRO/ORC network owners last.

See each composition README for its resource chain and topology-specific
activation and removal notes.
