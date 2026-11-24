# Mission 001 — Install and inspect Argo CD

**Track:** GitOps foundations  
**Environment:** Windows PowerShell + kind

## Mission outcome

Install Argo CD into a dedicated namespace, inspect its components and API resources, and understand the difference between Argo CD's reconciliation loop and Kubernetes workload controllers.

The learning session used the kind context kind-prod-sim, with one control-plane node and three workers.

## 1. Verify the target cluster

Run in PowerShell:

```powershell
kubectl config current-context
kubectl get nodes -o wide
kubectl get namespaces
```

Expected context: kind-prod-sim.

**Stop if the context is not the disposable lab cluster.** Do not install or experiment against a production context.

## 2. Create the namespace

```powershell
kubectl create namespace argocd
```

If it already exists, verify it:

```powershell
kubectl get namespace argocd
```

A dedicated namespace groups Argo CD's namespaced components and makes inspection and lifecycle operations easier. It is not a complete security boundary. Cluster-scoped resources remain cluster-scoped.

## 3. Install Argo CD

The session used the upstream stable manifest URL:

```powershell
kubectl apply -n argocd --server-side --force-conflicts `
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Reproducibility note:** stable is a mutable branch. For repeatable team or production installation, select and record an explicit Argo CD release, review its release notes and manifest, and test upgrades deliberately.

Flag meanings:
- -n argocd supplies the namespace for namespaced resources.
- --server-side uses Kubernetes server-side apply and field ownership tracking.
- --force-conflicts allows taking ownership of conflicting fields. Use deliberately; it is not a generic troubleshooting flag.

## 4. Verify components and API resources

```powershell
kubectl get pods -n argocd
kubectl get deployments -n argocd
kubectl get statefulsets -n argocd
kubectl get services -n argocd
kubectl get crds | Select-String argoproj.io
```

The session observed seven Pods Ready:
- argocd-application-controller-0
- argocd-applicationset-controller-...
- argocd-dex-server-...
- argocd-notifications-controller-...
- argocd-redis-...
- argocd-repo-server-...
- argocd-server-...

Pod suffixes are generated and will differ.

Inspect cluster-scoped RBAC too:

```powershell
kubectl get clusterroles | Select-String argocd
kubectl get clusterrolebindings | Select-String argocd
```

## 5. Understand the components

| Component | Responsibility |
|---|---|
| argocd-server | API server and web UI; handles client/API requests |
| argocd-application-controller | Observes Application resources, compares desired/live state, and performs reconciliation/sync actions |
| argocd-repo-server | Fetches repositories and generates manifests using configured tooling |
| argocd-applicationset-controller | Generates and manages Application resources from ApplicationSet definitions |
| argocd-dex-server | Optional identity federation component for SSO integrations |
| argocd-redis | Cache used by Argo CD components |
| argocd-notifications-controller | Evaluates notification triggers and sends configured notifications |

The components cooperate; Argo CD is not one monolithic deployment process. Exact deployment modes and responsibilities can vary by release and configuration.

## 6. Access the UI locally

In a dedicated PowerShell terminal:

```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Keep that terminal open. Visit https://localhost:8080.

The browser may warn about the local self-signed certificate. This is expected for this local port-forward setup; do not train yourself to ignore certificate warnings on real services.

In a second PowerShell terminal, retrieve the initial admin password:

```powershell
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($secret))
```

Username: admin.

The password is stored in a Kubernetes Secret and the command Base64-decodes it. Base64 is encoding, not encryption. Never paste the password into documentation, screenshots, Git commits, chat, or shell scripts.

If a bootstrap credential has been exposed, rotate it after first login and remove the initial secret according to the Argo CD documented procedure. Use a secret manager and SSO/RBAC in production rather than relying on the bootstrap admin account.

## 7. Mental model: who reconciles what?

```text
Git repository
     |
     v
repo-server renders manifests
     |
     v
Application controller compares desired vs live
     |
     +---- OutOfSync: report drift
     |
     +---- Sync policy permits: apply desired manifests
                                  |
                                  v
                           Kubernetes API
                                  |
                  Kubernetes controllers reconcile
                    Deployment / Service / etc.
```

Argo CD reconciles the application definition against Git; Kubernetes controllers reconcile individual Kubernetes resources toward their declared specifications. Argo CD does not replace those controllers.

## 8. Checkpoint — predict before proceeding

Do not look up the answer before choosing.

**Scenario:** A Deployment is managed by Argo CD. Someone manually changes the live replica count from 3 to 5, but Git still declares 3 replicas. What do you expect first?

- A. Kubernetes rejects the manual change because Argo CD owns the Deployment.
- B. The live object can change; Argo CD detects drift and reports OutOfSync. Whether it automatically corrects the change depends on sync/self-heal configuration.
- C. Git is automatically updated to 5 replicas.

Record your choice and reasoning. We will test it in Mission 003 rather than merely memorizing the definition.

## 9. Troubleshooting

### Pods are Pending

```powershell
kubectl describe pods -n argocd
kubectl get events -n argocd --sort-by=.lastTimestamp
kubectl describe nodes
```

Check scheduling constraints, available CPU/memory, image pulls, and node health.

### A Pod is CrashLoopBackOff

```powershell
kubectl describe pod <pod-name> -n argocd
kubectl logs <pod-name> -n argocd
kubectl logs <pod-name> -n argocd --previous
```

### UI is unreachable

```powershell
kubectl get svc argocd-server -n argocd
kubectl get endpointslice -n argocd
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
```

Confirm port-forward is still running and inspect Service endpoints and server Pod health.

## 10. Completion evidence

- [ ] Current context is the intended kind lab.
- [ ] All Argo CD Pods are Ready.
- [ ] Services are present.
- [ ] Argo CD CRDs are installed.
- [ ] UI is reachable through port-forward.
- [ ] Explain the repo-server/controller split.
- [ ] Explain why namespace placement does not namespace cluster-scoped RBAC/CRDs.

## Next mission

Mission 002 connects a Git repository and deploys a small application. We keep the first workload simple to isolate GitOps behavior before introducing the payment platform and stressed dependencies.