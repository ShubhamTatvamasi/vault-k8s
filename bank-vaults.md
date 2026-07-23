# bank-vaults

```bash
kubectl get secret vault-unseal-keys -o yaml -n vault | \
  yq '.data |= with_entries(.value |= @base64d)'
```

---

### OpenBao


```bash
kubectl get secret openbao-unseal-keys -o yaml -n openbao | \
  yq '.data |= with_entries(.value |= @base64d)'
```
