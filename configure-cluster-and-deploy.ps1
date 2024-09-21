# Delete the kind cluster if it exists
kind delete cluster --name localkindcluster

# Create the kind cluster
kind create cluster --config ./kind-config.yaml

# Add the ArgoCD helm repo
helm repo add argo https://argoproj.github.io/argo-helm

# Wait for the cluster to be ready
kubectl wait --for=condition=Ready node --all --timeout=5m

echo "Sleep for a bit to let the cluster settle"
Start-Sleep -Seconds 10


# Install ArgoCD
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f .\argo-local-setup.yaml


# Wait for the ArgoCD pods to be ready
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=5m
echo "Sleep for a bit to let the ArgoCD settle"
Start-Sleep -Seconds 20


# Capture the secret from kubectl output
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$decodedSecret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))
Write-Output "ArgoCD Initial Admin Password: $decodedSecret"



# Install the Bootstrap Helm Chart
helm upgrade --install bootstrap ./BootstrapCluster -n bootstrap-cluster --create-namespace