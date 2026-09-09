# bank-vaults

### Vault

```bash
kubectl get secret bank-vaults -o yaml -n vault | \
  yq '.data |= with_entries(.value |= @base64d)'
```

---

### OpenBao


```bash
kubectl get secret bank-vaults -o yaml -n openbao | \
  yq '.data |= with_entries(.value |= @base64d)'
```
