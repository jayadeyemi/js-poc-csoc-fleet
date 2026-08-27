# Direct spoke application adaptation

The `references/config` and `references/gitops` forks are design inputs, not
cluster roots. Applications extracted from them are deployed to the spoke API,
never to a CSOC management cluster.

The first accepted instance is the minimal `test-poc/hello-app/dev` manifest in
`environments/staging`. It uses one application replica and the smallest spoke
worker bounds currently supported by the graph. It is the compatibility harness
for direct delivery, interruption, repeat reconciliation, and bounded scaling.

For each larger reference application:

1. Record upstream repository and commit; inventory CRDs, charts, images,
   secrets, storage, networking, and upgrade hooks.
2. Create a namespace-scoped base and minimal dev overlay with pinned sources.
   Replace embedded credentials with an external secret contract.
3. Put persistent data on a dedicated Cinder PVC with a retention policy. Never
   use node boot storage for application data and never auto-prune the PVC.
4. Deliver through a reconciled CAPI addon or spoke-local Argo root, and expose
   readiness from actual workload and storage conditions.
5. Test install, repeat, interruption, upgrade, rollback, PVC reattachment, and
   removal-with-retention before assigning a staging tuple.
