# vault


policy policy name: superuser
```
path "*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

create new token
```
vault write auth/token/create policies=superuser period=720h
```

create root token
```
vault write auth/token/create -force
```



