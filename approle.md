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

