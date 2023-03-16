# linux

Start Vault in dev mode:
```bash
vault server -dev
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
vault kv get -mount=secret -version=01 first-secret
```

Create secret:
```bash
vault kv put -mount=secret second-secret user=admin01
```

