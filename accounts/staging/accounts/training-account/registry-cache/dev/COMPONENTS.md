# Training account registry-cache dev components

This tuple owns a dedicated spoke with the standard identity, dedicated network,
keypair, CAPI/CAPO cluster, Calico, OpenStack CCM, Cinder CSI, autoscaler, and
spoke-local Argo CD graphs.

Its only workload application is a two-upstream pull-through registry cache.
Each cache Deployment has a separate retained 10-GiB Cinder PVC; Services are
ClusterIP-only. The dev adaptation requires no S3, TLS, or registry credentials.

Availability and deployment gates are maintained in the workspace-root
`STAGING-APPLICATION-AVAILABILITY.md` report.
