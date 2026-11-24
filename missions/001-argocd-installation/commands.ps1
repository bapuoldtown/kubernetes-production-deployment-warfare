# Mission 001 - Argo CD installation
# Run only against the disposable kind learning cluster.
$ErrorActionPreference = "Stop"

Write-Host "Current Kubernetes context:"
kubectl config current-context

$context = kubectl config current-context
if ($context -ne "kind-prod-sim") {
    throw "Wrong context '$context'. Expected 'kind-prod-sim'. Stop and verify your target cluster."
}

kubectl get namespace argocd *> $null
if ($LASTEXITCODE -ne 0) {
    kubectl create namespace argocd
} else {
    Write-Host "Namespace argocd already exists."
}

# The upstream stable URL is mutable. Replace with a manifest URL pinned to
# the Argo CD release you have reviewed and tested for reproducible use.
kubectl apply -n argocd --server-side --force-conflicts `
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "Pods:"
kubectl get pods -n argocd
Write-Host "Services:"
kubectl get services -n argocd
Write-Host "CRDs:"
kubectl get crds | Select-String argoproj.io

Write-Host "Installation checks finished. Retrieve the bootstrap password manually; never commit it."
