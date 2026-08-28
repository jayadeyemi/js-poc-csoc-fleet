# test-poc shared development cluster (v2)

This is the environment/staging candidate for the first second-generation
acceptance. Its candidate branch is activated only after dev accepts the exact
coordinated commits and the live staging preflight passes.

Activation creates independent `SpokeAccount`, `MachineProfile`,
`SpokeNetwork`, `WorkloadCluster`, `SpokeNodePool`, `ClusterFoundation`, and
`SpokeRegistration` instances. The application tuple is kept separately under
`smoke/` and references the reusable cluster through `clusterRef`.

Bootstrap creates and labels `spokeclusters-test-poc`, loads the restricted
account credential, and creates `test-poc-workload-cloud-config` before this
package is activated. Registration consumes the environment-published CSOC API
endpoint rather than a fleet field. Registration precedes foundation delivery.
Node-pool instances set bounds but never set replicas.

The candidate is control plane `1`, system `1..1`, CPU `0..1`; flavors are
Jetstream numeric IDs `2` and `3`, all roots are 20 GiB, and retained claim
maxima are hub DB `1`, homes `1`, and Prometheus `1`.
