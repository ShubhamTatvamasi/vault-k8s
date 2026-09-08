# bank-vaults

```bash
kubectl get secret bank-vaults -o yaml -n vault | \
  yq '.data |= with_entries(.value |= @base64d)'
```

### OLD

```bash
kubectl get secret vault-unseal-keys -o yaml -n vault | \
  yq '.data |= with_entries(.value |= @base64d)'
```

---

### OpenBao


```bash
kubectl get secret bank-vaults -o yaml -n openbao | \
  yq '.data |= with_entries(.value |= @base64d)'
```
