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

https://www.vaultproject.io/docs/platform/k8s/helm

