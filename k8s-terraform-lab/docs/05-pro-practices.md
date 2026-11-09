# Phase 5 - Pratiques pro (2 semaines)

Dossier : `05-pipeline/`

## 1. State distant avec MinIO

```bash
docker run -d --name minio -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minio -e MINIO_ROOT_PASSWORD=minio12345 \
  -v ~/minio-data:/data \
  quay.io/minio/minio server /data --console-address ":9001"
```

Créer un bucket `tfstate` via la console (localhost:9001), puis :

```hcl
terraform {
  backend "s3" {
    bucket                      = "tfstate"
    key                         = "lab/workloads.tfstate"
    region                      = "us-east-1"
    endpoints                   = { s3 = "http://localhost:9000" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
```

```bash
export AWS_ACCESS_KEY_ID=minio AWS_SECRET_ACCESS_KEY=minio12345
terraform init -migrate-state
```

(Les noms d'options du backend S3 ont évolué selon les versions de Terraform : vérifie la doc si `init` se plaint.)

- [ ] Migrer un state local vers MinIO.
- [ ] Activer le locking (selon version : `use_lockfile = true`) et tester deux apply simultanés.

## 2. Qualité et sécurité

```bash
terraform fmt -check -recursive
terraform validate
tflint --init && tflint
mise use -g checkov trivy
checkov -d .
trivy config .
```

- [ ] Corriger ce que remontent les scanners (ou justifier une exception).
- [ ] `pre-commit` avec fmt / validate / tflint.

## 3. Tests Terraform natifs

`tests/app.tftest.hcl` :

```hcl
run "creates_container" {
  command = plan

  variables {
    name = "test"
    port = 8085
  }

  assert {
    condition     = docker_container.web.name == "test"
    error_message = "Nom de conteneur inattendu"
  }
}
```

```bash
terraform test
```

- [ ] Tests `plan` puis `apply` sur ton module de la phase 1.

## 4. Environnements

- [ ] Dossiers `envs/dev` et `envs/prod` avec des `tfvars` distincts, **ou** workspaces :
```bash
terraform workspace new dev
terraform workspace list
```
- [ ] Comprendre pourquoi les workspaces ne remplacent pas une vraie séparation prod / dev.

## 5. CI/CD avec GitHub Actions

`.github/workflows/terraform.yml` (squelette) :

```yaml
name: terraform
on:
  pull_request:
  push:
    branches: [main]

jobs:
  plan:
    runs-on: self-hosted      # runner dans ton WSL
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check -recursive
      - run: terraform init
      - run: terraform validate
      - run: terraform plan -out=tfplan

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    runs-on: self-hosted
    environment: lab
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

- [ ] Installer un runner self-hosted dans WSL (Settings > Actions > Runners du repo).
- [ ] Plan sur PR, apply sur merge.
- [ ] Ajouter checkov / trivy comme étape bloquante.

## 6. Secrets
- [ ] Sealed Secrets (Helm) : chiffrer un Secret et le committer.
- [ ] Ou External Secrets + Vault en mode dev (`helm install vault hashicorp/vault --set server.dev.enabled=true`).
- [ ] Ne jamais committer de `.tfvars` avec des secrets.

## Checklist
- [ ] State distant avec locking
- [ ] Pipeline qui plan sur PR et apply sur merge
- [ ] Scans sécu intégrés
- [ ] `terraform test` sur un module
- [ ] Un secret chiffré commité proprement
