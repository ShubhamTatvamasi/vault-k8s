# external-secrets

Add Kubernetes Auth method:
```bash
vault write auth/kubernetes/config \
  kubernetes_host=https://kubernetes.default.svc
```

Create a role for `external-secrets`:
```bash
vault write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=external-secrets-reader
```
