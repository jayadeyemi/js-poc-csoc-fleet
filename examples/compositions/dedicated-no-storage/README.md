# Dedicated network without pre-provisioned storage

Use this complete composition when the account already has the Jetstream2
allocation router but needs a dedicated spoke network and subnet. The network
graph imports that router as unmanaged, creates the network/subnet/interface,
and publishes the connection consumed by `SpokeCluster`. The cluster still
installs Cinder CSI and can dynamically provision PVCs; “without storage” means
there is no independent `SpokeVolume` graph instance.

Add it by copying this directory to `accounts/<identity>`, replacing every
`example-dedicated` value and reviewed identifier, and listing the directory in
`accounts/kustomization.yaml`. Add a `SpokeVolume` later as a separate file.
Remove the volume independently; remove the cluster only through the retirement
sequence in `examples/README.md`. Never remove the network graph while CAPI
machines or load balancers still use it.
