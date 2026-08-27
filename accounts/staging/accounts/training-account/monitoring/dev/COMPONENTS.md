# Training account monitoring dev components

This tuple owns a dedicated spoke with the standard identity, dedicated network,
keypair, CAPI/CAPO cluster, Calico, OpenStack CCM, Cinder CSI, autoscaler, and
spoke-local Argo CD graphs.

Its only workload application is kube-prometheus-stack `84.3.0`, reduced to an
internal Prometheus, operator, kube-state-metrics, and node-exporter footprint.
Prometheus uses a retained 10-GiB Cinder volume. Grafana, Alertmanager, and
default alert rules are disabled for this minimal dev instance.

Availability and deployment gates are maintained in the workspace-root
`STAGING-APPLICATION-AVAILABILITY.md` report.
