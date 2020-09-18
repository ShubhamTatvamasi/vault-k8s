# vault-k8s

Add hashicorp helm repo 
```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

update repo
```bash
helm repo update
```

search for vault
```bash
helm search repo hashicorp/vault
```

download chart
```bash
helm fetch --untar hashicorp/vault
```

create new namespace
```bash
kubectl create namespace vault
```

install vault
```bash
helm install vault hashicorp/vault -n vault \
  --set server.dataStorage.enabled=false \
  --set server.service.type=NodePort \
  --set server.service.nodePort=30082
```

http://k8s.shubhamtatvamasi.com:30082

---

Add Ingress value
```yaml
kubectl apply -f - << EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: vault
spec:

  tls:
  - hosts:
      - vault.k8s.shubhamtatvamasi.com
    secretName: letsencrypt

  rules:
  - host: vault.k8s.shubhamtatvamasi.com
    http:
      paths:
      - backend:
          serviceName: vault-internal
          servicePort: 8200
EOF
```

https://vault.k8s.shubhamtatvamasi.com:30443

https://www.vaultproject.io/docs/platform/k8s/helm

