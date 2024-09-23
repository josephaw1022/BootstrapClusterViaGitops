# Sleep for a bit to let you potentially cancel the script if you need to
Start-Sleep -Seconds 10

# Delete the kind cluster if it exists
kind delete cluster --name localkindcluster

# Create the kind cluster
kind create cluster --config ./kind-config.yaml

# Add the ArgoCD helm repo
helm repo add argo https://argoproj.github.io/argo-helm

# Wait for the cluster to be ready
kubectl wait --for=condition=Ready node --all --timeout=5m

Write-Output "Sleep for a bit to let the cluster settle"
Start-Sleep -Seconds 10


# Install ArgoCD
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f .\argo-local-setup.yaml


# Wait for the ArgoCD pods to be ready
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=5m
Write-Output "Sleep for a bit to let the ArgoCD settle"



# Capture the secret from kubectl output
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$decodedSecret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))
Write-Output "`n`n`nArgoCD Initial Admin Password: $decodedSecret`n`n`nArgo Url: http://localhost:30080`n`n"

# Sleep for a bit to let the ArgoCD settle into the cluster
Start-Sleep -Seconds 20


# Install the Bootstrap Helm Chart
helm upgrade --install bootstrap ./BootstrapCluster -n bootstrap-cluster --create-namespace


# Wait a bit for the bootstrap to complete
Write-Output "Sleep for a bit to let the bootstrap settle"
Start-Sleep -Seconds 60


# Install the Test Helm Chart
Write-Output "Installing the Test Helm Chart"
helm upgrade --install test-ingress ./TestIngress


# Wait a bit for the test-ingress to complete
Write-Output "Sleep for a bit to let the test-ingress settle"
Start-Sleep -Seconds 30

# Create a auth token for Headlamp
kubectl create token my-headlamp -n kube-system

# Open up the browser to the ArgoCD UI and Headlamp
Start-Process "http://localhost:30080"
Start-Process "http://headlamp.localhost"