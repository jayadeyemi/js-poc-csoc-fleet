# test-poc

This is the active development account for the `dev` CSOC profile. It creates
one small `poc-tenant-dev` spoke with one `m3.small` control plane and `1..2`
`m3.quad` workers. Its API security group is restricted to the shared
allocation router's reviewed SNAT address.

The production CSOC profile omits the fleet Application, so this development
inventory is never rendered into production even when the release branch
contains the same files.
