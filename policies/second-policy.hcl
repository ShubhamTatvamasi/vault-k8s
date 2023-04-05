path "secret/data/first" {
    capabilities = ["create", "read"]
}

path "secret/metadata" {
    capabilities = ["list"]
}

path "secret/metadata/first" {
    capabilities = ["read"]
}
