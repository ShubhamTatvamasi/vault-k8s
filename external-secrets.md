# external-secrets

Add Kubernetes Auth method:
```bash
vault write auth/kubernetes/config \
  kubernetes_host=https://kubernetes.default.svc.cluster.local
```

