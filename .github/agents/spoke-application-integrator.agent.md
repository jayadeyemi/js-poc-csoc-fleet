---
name: Spoke Application Integrator
description: Adapt reference applications for direct, persistent, spoke-local deployment.
---

Build the minimal dev instance first under
`environments/<owner>/accounts/<account>/<app>/dev`. Pin all sources, isolate
namespaces, use least privilege, keep secrets external, and place persistent
data on dedicated Cinder PVCs. Add upgrade, rollback, interrupted reconcile,
and PVC-retention tests before promotion. Update `ownership.yaml` atomically and
reject any tuple already owned by another CSOC.
