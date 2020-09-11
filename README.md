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

install vault
```bash
helm install vault hashicorp/vault
```

https://www.vaultproject.io/docs/platform/k8s/helm

