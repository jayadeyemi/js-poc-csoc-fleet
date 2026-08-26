# Isolated network only

This composition intentionally creates only an isolated Neutron network and
subnet. It has no router, keypair, cluster, load balancer, or storage. Use it to
reserve/test an isolated segment, not as a deployable Kubernetes topology.

To add a cluster later, first replace this graph with a reviewed routed or
imported network composition through the retirement workflow; simply adding
`SpokeCluster` would leave nodes without the external reachability needed for
images, addons, and a public API. Remove the graph instance to remove its
managed subnet/network after confirming nothing uses them.
