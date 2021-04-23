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

### Ingress

Install with tls:
```bash
helm install vault hashicorp/vault \
  --create-namespace \
  --namespace vault \
  --set server.ingress.enabled=true \
  --set "server.ingress.tls[0].secretName=vault-tls" \
  --set server.ingress.annotations."cert-manager\.io/cluster-issuer"=letsencrypt \
  --set "server.ingress.hosts[0].host=vault.k8s.shubhamtatvamasi.com" \
  --set "server.ingress.tls[0].hosts[0]=vault.k8s.shubhamtatvamasi.com"
```

install with http:
```bash
helm install vault hashicorp/vault \
  --create-namespace \
  --namespace vault \
  --set server.ingress.enabled=true \
  --set "server.ingress.hosts[0].host=vault.k8s.shubhamtatvamasi.com"
```

### NodePort

install vault
```bash
helm install vault hashicorp/vault -n vault \
  --set server.dataStorage.enabled=false \
  --set server.service.type=NodePort \
  --set server.service.nodePort=30082
```

http://k8s.shubhamtatvamasi.com:30082

---

Create TLS secret:
```bash
kubectl create secret tls letsencrypt \
  --key ./shubhamtatvamasi.com.key \
  --cert ./fullchain.cer \
  -n vault
```

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

