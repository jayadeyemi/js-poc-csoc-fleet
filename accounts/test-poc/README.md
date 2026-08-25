# test-poc

This is the active development account for the `dev` CSOC profile. It creates
one small `poc-tenant-dev` spoke with one `m3.small` control plane and `1..2`
`m3.quad` workers. Its API security group is restricted to the shared
allocation router's reviewed SNAT address.

The tracked public key is a write-once account input. `SpokeKeypair` passes it
to an ORC-managed Nova `KeyPair` and `SpokeCluster` consumes the generated
connection ConfigMap. The matching private key remains only on the operator's
local host.

The spoke Hello service receives its own public Octavia load balancer on the
private spoke subnet. `loadBalancerSourceRanges` permits only the tracked local
operator egress `/32`; it does not expose the Kubernetes API or reuse its load
balancer.

The production CSOC profile omits the fleet Application, so this development
inventory is never rendered into production even when the release branch
contains the same files.
