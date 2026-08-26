# Fully managed routed topology

This composition creates and owns the private network, subnet, router, router
interface, keypair, and CAPI cluster. It imports only the reviewed external
network. Use it when the account must not share the allocation router.

Activation requires an unused node CIDR and enough Neutron router, port, and
floating-IP quota. Removal order is workload → CAPI cluster → router interface
→ router → subnet/network. Do not replace this graph with another network kind
in place; its connection ConfigMap is immutable.
