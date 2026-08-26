# Attach an existing network (no network creation)

Use this composition when Neutron network, subnet, and router objects already
exist. `SpokeNetworkImportConfig` stores reviewed exact UUIDs; `ImportedSpokeNetwork`
creates unmanaged ORC import objects and the connection ConfigMap. It does not
create, mutate, or delete the imported OpenStack topology.

All three IDs must be in the identity's project and describe one connected
topology. Replace the example IDs before activation. “Without network” means
without **network creation**—`SpokeCluster` still requires one network graph to
produce its connection. Remove the cluster before removing the import graph;
removing the graph never authorizes deletion of imported resources.
