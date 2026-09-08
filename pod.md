# pod

Get inside Vault pod:
```bash
kubectl exec -it -n vault vault-0 -c vault -- \
  sh -c "export VAULT_TOKEN='$(kubectl get secret \
    -n vault bank-vaults -o jsonpath='{.data.vault-root}' | base64 -d)'; \
  exec sh"
```
