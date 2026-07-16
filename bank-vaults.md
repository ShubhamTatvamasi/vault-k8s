# bank-vaults

```bash
kubectl get secret vault-unseal-keys -o yaml -n vault | \
  yq '.data |= with_entries(.value |= @base64d)'
```
