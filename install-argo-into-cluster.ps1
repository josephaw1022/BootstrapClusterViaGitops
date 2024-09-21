# Delete the kind cluster if it exists
kind delete cluster --name localkindcluster

# Create the kind cluster
kind create cluster --config ./kind-config.yaml

# Add the ArgoCD helm repo
helm repo add argo https://argoproj.github.io/argo-helm

# Wait for the cluster to be ready
kubectl wait --for=condition=Ready node --all --timeout=5m

echo "Sleep for a bit to let the cluster settle"
Start-Sleep -Seconds 30


# Install ArgoCD
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace 


