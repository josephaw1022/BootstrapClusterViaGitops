# Capture the secret from kubectl output
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$decodedSecret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))
Write-Output "`n`n`nArgoCD Initial Admin Password: $decodedSecret`n`n`nArgo Url: http://localhost:30080`n`n"
