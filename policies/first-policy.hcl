path "sys/mounts" {
    capabilities = ["read"]
}

path "sys/policies/acl" {
    capabilities = ["read", "list"]
}

path "secret/*" {
    capabilities = ["read"]
}

path "secret/second-secret" {
    capabilities = ["denay"]
}
