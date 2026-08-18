---
applyTo: "customers/**"
---
# js-poc-csoc-fleet conventions

All files under `customers/` are Kubernetes custom resource manifests applied by Argo CD.

## cluster.yaml

- `apiVersion: csoc.js2.org/v1alpha1`, `kind: SpokeCluster`
- `metadata.name`: `<customer-id>-<environment>` — globally unique, lowercase, hyphens only, no underscores
- `metadata.namespace: spokeclusters`
- `csoc.js2.org/type: spoke` is **not set here** — the registration controller adds it automatically

## applications.yaml

- `cluster:` must exactly match the sibling `cluster.yaml` `metadata.name`
- `applications[].name` must match a top-level directory in `js-poc-csoc-app-catalog`
- `applications[].release` is a semver or date-based tag (e.g. `"2026.08"`, `"4.7.1"`)

## Naming

Pattern: `<customer-id>-<environment>`
- Customer IDs: lowercase, hyphen-separated (`university-a`, `nci`, `research-proj-x`)
- Environments: `dev`, `staging`, `prod`
- Examples: `nci-prod`, `university-a-dev`, `research-proj-x-staging`
