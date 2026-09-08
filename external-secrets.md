# external-secrets

Add Kubernetes Auth menthod:
```bash
vault write auth/kubernetes/config \
  kubernetes_host=https://kubernetes.default.svc.cluster.local
```

