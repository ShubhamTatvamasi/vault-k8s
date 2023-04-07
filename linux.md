# linux

Start Vault in dev mode:
```bash
vault server -dev
```

Vault print token:
```bash
vault print token
```

Add the Vault address environment variable:
```bash
export VAULT_ADDR='http://127.0.0.1:8200'
```

Check the Vault status:
```bash
vault status
```

Read secrets from vault:
```bash
vault kv get -mount=secret first-secret
vault kv get -mount=secret -version=1 first-secret # get a specfic version
```

Create secret:
```bash
vault kv put -mount=secret second-secret user=admin01
vault kv put -mount=secret second-secret user=admin02 # this will create a new version
```

Delete a version:
```bash
vault kv delete -mount=secret -versions=2 first-secret
vault kv delete -mount=secret -versions=2,1 first-secret # delete multiple versions
```

Undelete a version:
```bash
vault kv undelete -mount=secret -versions=2 first-secret
vault kv undelete -mount=secret -versions=2,1 first-secret # undelete multiple versions
```

Permanently delete a secret:
```bash
vault kv destroy -mount=secret -versions=2 first-secret
```

---

Login to vault server:
```bash
vault login -method=userpass username=username
```

