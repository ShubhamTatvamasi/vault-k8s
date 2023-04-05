# approle

Enable approle Authentication Methods \
http://127.0.0.1:8200/ui/vault/settings/auth/enable

Create an approle:
```bash
vault write auth/approle/role/jenkins token_policies="jenkins-role-policy"
```

Read the approle:
```bash
vault read auth/approle/role/jenkins
```

Get the role ID:
```bash
vault read auth/approle/role/jenkins/role-id
```

Genetrate secret ID:
```bash
vault write -f auth/approle/role/jenkins/secret-id
```

Login to vault via approle:
```bash
vault write auth/approle/login \
role_id="50cccb7e-2b4f-5a47-6822-aec626350384" \
secret_id="8f21a27b-97a6-2abd-bcd6-3cd23490cd86"
```
