# Learning lab architecture

## Two cooperating systems

1. **Management plane:** Argo CD, its controllers, repository integration, and Application definitions.
2. **Workload plane:** the sample payment platform and its dependencies.

Argo CD observes Application definitions and compares the desired state rendered from Git with live Kubernetes objects. Depending on sync policy, it can report drift or apply changes. Kubernetes controllers then reconcile their own resources, such as Deployment to ReplicaSet to Pods.

## Conceptual topology

```text
                 Git repository
                      |
                      v
              Argo CD repo-server
                      |
             rendered desired state
                      |
                      v
             Argo CD application
                controller
                      |
               Kubernetes API
                      |
        +-------------+--------------+
        |             |              |
     Deployment     Service       Config/Secret
        |             |              |
     ReplicaSet    EndpointSlice   Pods consume
        |                            configuration
      Pods
        |
  +-----+------+--------------------------+
  |            |            |             |
 API         Cache       Database A    Database B
  |
 Kafka client
  |
 Kafka broker 1 / broker 2 / broker 3
```

This is a conceptual diagram. Actual sample manifests and service topology will be introduced incrementally.

## Important boundaries

- A namespace scopes namespaced resources, but CRDs, ClusterRoles, and other cluster-scoped resources are not namespaced.
- Argo CD's application controller talks to the Kubernetes API. It does not replace the Deployment controller, ReplicaSet controller, scheduler, kubelet, CNI, CSI, or container runtime.
- A Deployment rollout changes application Pods. It does not automatically make a database schema change backward-compatible or guarantee Kafka consumer compatibility.
- A successful Pod rollout is not proof that the end-to-end business transaction is healthy.
- A local kind cluster is useful for learning control loops and controlled failure scenarios, but it is not a production multi-failure-domain environment.

## Questions for every design

1. What is the desired state and where is it declared?
2. Which controller owns the next action?
3. What signal proves the new version is safe?
4. What dependency capacity is consumed during surge?
5. What happens to in-flight requests and background work?
6. Can old and new application versions coexist?
7. What is the rollback path, and is it safe after data changes?
8. What evidence should an on-call engineer use?