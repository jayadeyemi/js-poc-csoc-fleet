# Dedicated network with a Cinder volume

This is the dedicated-network composition plus an independent `SpokeVolume`.
The resource chain is identity → environment/keypair/network → cluster, while
the volume depends only on identity and immutable storage configuration. The
volume is not a Kubernetes PVC and is not automatically attached to a node.

Copy and rename the complete directory to activate it. Remove `SpokeVolume`
from the active kustomization when storage is no longer desired, merge that
intent, and explicitly delete the graph instance only after confirming the
data may be destroyed. Do not delete the account namespace as a shortcut.
