# Vault + External Secrets Operator — Manual Setup

This documents the manual, imperative Vault configuration behind the
`ClusterSecretStore`/`ExternalSecret` setup in `infrastructure/base/external-secrets/`
and `secrets/external-secrets/`. None of the commands below are captured in
git — they configure live state inside Vault's own storage. If Vault's data
is ever lost or rebuilt from scratch, these steps must be re-run before any
`ExternalSecret` will sync.

## Prerequisites

- Vault is deployed and unsealed (`infrastructure/base/vault`).
- External Secrets Operator is deployed (`infrastructure/base/external-secrets/operator`).
- You have `kubectl` access to the cluster.

## 1. Get a shell inside the Vault pod

```bash
kubectl exec -it -n vault vault-0 -c vault -- sh
```

Every `exec` session starts with no environment set. Get the root token from
your own terminal (a second window, outside the pod):

```bash
kubectl get secret -n vault bank-vaults -o jsonpath='{.data.vault-root}' | base64 -d
```

Then, inside the pod shell:

```sh
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=<paste-root-token-here>
```

All commands below assume you're inside this shell with those two variables set.

## 2. Confirm the KV v2 engine and Kubernetes auth exist

These already existed on this cluster before this setup (likely from an
earlier bank-vaults default config) — check before creating them again:

```sh
vault secrets list
vault auth list
```

If `secret/` (type `kv`, version 2) is missing:

```sh
vault secrets enable -path=secret -version=2 kv
```

If `kubernetes/` auth is missing:

```sh
vault auth enable kubernetes

vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc"
```

## 3. Create the ESO read-only policy

Written via stdin — the pod's filesystem is read-only, so you can't write a
policy file to `/tmp` first.

```sh
vault policy write external-secrets-reader - <<'EOF'
path "secret/data/cnpg/*" {
  capabilities = ["read"]
}
path "secret/data/airflow/*" {
  capabilities = ["read"]
}
path "secret/data/opensearch/*" {
  capabilities = ["read"]
}
path "secret/data/tls/*" {
  capabilities = ["read"]
}
path "secret/metadata/cnpg/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/airflow/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/opensearch/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/tls/*" {
  capabilities = ["read", "list"]
}
EOF
```

Adding a new secret prefix later (e.g. `secret/foo/*`) means appending two
more `path` blocks here (`data/foo/*` read, `metadata/foo/*` read+list) and
re-running this command — `vault policy write` is idempotent, it just
replaces the named policy.

## 4. Create the Kubernetes auth role for ESO

This ties the policy to the External Secrets Operator's own ServiceAccount —
no static credential is stored anywhere; Vault verifies the ServiceAccount
token live against the Kubernetes API on every login.

```sh
vault write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=external-secrets-reader \
  ttl=1h
```

## 5. Verify

```sh
vault policy read external-secrets-reader
vault read auth/kubernetes/role/external-secrets
```

Exit the pod shell (`exit` or Ctrl+D) — the rest of the steps below write
secret data and can be run either from inside the pod shell (continuing with
`vault kv put ...`) or from your own terminal via `kubectl exec`.

## 6. Write secret data into Vault

Each secret lives at a path mirroring its Kubernetes name. Run one
`vault kv put` per secret, replacing the placeholder values with the real
ones (from decrypting the corresponding SealedSecret, or freshly generated
values for a new secret).

```sh
vault kv put secret/cnpg/airflow-basic-auth \
  password="<value>"

vault kv put secret/airflow/metadata-connection \
  connection="<value>" \
  kedaConnection="<value>"

vault kv put secret/airflow/opensearch-connection \
  connection="<value>" \
  password="<value>" \
  username="<value>"

vault kv put secret/airflow/fernet-key \
  fernet-key="<value>"

vault kv put secret/airflow/connections-import \
  connections.yaml="<value>"

vault kv put secret/airflow/connections \
  AIRFLOW_CONN_MY_HARBOR="<value>" \
  AIRFLOW_CONN_MY_POSTGRES="<value>" \
  AIRFLOW_CONN_MY_VM="<value>"

vault kv put secret/airflow/git-credentials \
  GIT_SYNC_USERNAME="<value>" \
  GIT_SYNC_PASSWORD="<value>" \
  GITSYNC_USERNAME="<value>" \
  GITSYNC_PASSWORD="<value>"

vault kv put secret/opensearch/admin-credentials \
  username="<value>" \
  password="<value>" \
  cookie="<value>"

vault kv put secret/tls/shubhamtatvamasi-tls \
  tls.crt="<value>" \
  tls.key="<value>" \
  ca.crt="<value>"
```

> Passing secret values as CLI arguments puts them in your local shell
> history. For anything sensitive, prefer piping JSON via stdin instead:
> `echo '{"password":"..."}' | vault kv put secret/cnpg/airflow-basic-auth -`

### Decrypting existing SealedSecrets to get current values

If migrating a secret that already exists as a `SealedSecret` in git, decrypt
it first with the cluster's sealed-secrets recovery private key:

```bash
kubeseal --recovery-unseal \
  --recovery-private-key /path/to/sealed-secrets-key.yaml \
  --format yaml \
  < path/to/some-sealedsecret.yaml \
  > /tmp/decrypted.yaml
```

The `data:` block in the output holds the same base64-encoded values as a
plain Kubernetes Secret — decode each with `base64 -d` before writing to
Vault. Delete `/tmp/decrypted.yaml` once you're done; don't commit it.

## 7. Verify a path

```sh
vault kv get secret/cnpg/airflow-basic-auth
vault kv list secret/airflow
```

## 8. Confirm end-to-end via ESO

Once the `ClusterSecretStore` (`infrastructure/base/external-secrets/vault-store`)
and an `ExternalSecret` (e.g. `secrets/external-secrets/airflow/cnpg-system`)
are applied to the cluster, check:

```bash
kubectl get clustersecretstore vault-backend -o jsonpath='{.status.conditions}'
kubectl get externalsecret -n cnpg-system airflow-basic-auth -o jsonpath='{.status.conditions}'
kubectl get secret -n cnpg-system airflow-basic-auth
```

A healthy `ClusterSecretStore` shows `reason: Valid`; a healthy `ExternalSecret`
shows `reason: SecretSynced`.

## Adding a new secret later

1. Add the path prefix to the `external-secrets-reader` policy if it's a new
   top-level prefix (step 3), or skip if it fits an existing one.
2. `vault kv put secret/<new-path>` with the real values (step 6).
3. Add an `ExternalSecret` manifest under `secrets/external-secrets/...`
   referencing `secret/<new-path>` via `remoteRef.key`.
4. Point the relevant ResourceSet service `path:` at the new
   `secrets/external-secrets/...` (or `secrets/sealed-secrets/...`) directory.

## Known gap

Steps 2–5 (policy, role, auth config) are **not version-controlled** — they
only exist as live state in Vault's `file` storage backend. To make this
durable and reproducible, move policy/role definitions into
`vault.externalConfig` in `infrastructure/base/vault/helmrelease.yaml`, which
the `vault-configurer` sidecar already applies automatically on every Vault
restart.
