# Phase 1 - Terraform sans cloud (1 semaine)

Objectif : maîtriser le langage et le workflow, sans risque ni facture.

Dossier de travail : `01-terraform-basics/`

## Workflow de base

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Jour 1 : providers local / random

```hcl
# main.tf
terraform {
  required_providers {
    local  = { source = "hashicorp/local",  version = "~> 2.5" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

resource "random_pet" "name" {
  length = 2
}

resource "local_file" "hello" {
  filename = "${path.module}/hello-${random_pet.name.id}.txt"
  content  = "Bonjour ${random_pet.name.id}\n"
}

output "file" {
  value = local_file.hello.filename
}
```

Exercices :
- [ ] `apply`, puis relancer `apply` (idempotence).
- [ ] Modifier le contenu, lire le `plan` (update in-place vs replace).
- [ ] Supprimer le fichier à la main, relancer `plan` (drift).

## Jour 2 : variables, locals, outputs

- [ ] Variables avec `type`, `default`, `description`, `validation`.
- [ ] Fichier `terraform.tfvars` et `-var` en CLI.
- [ ] `locals` pour calculer des noms.
- [ ] Output `sensitive = true`.

## Jour 3 : count, for_each, expressions

```hcl
variable "users" {
  type    = set(string)
  default = ["alice", "bob", "carol"]
}

resource "local_file" "user" {
  for_each = var.users
  filename = "${path.module}/out/${each.key}.txt"
  content  = "user: ${each.key}"
}
```

- [ ] Refaire avec `count` puis supprimer un élément du milieu : observer le problème.
- [ ] Refaire avec `for_each` : comparer.
- [ ] Expressions `for`, `dynamic` block, `try`, `lookup`, `merge`, `templatefile`.

## Jour 4 : provider docker

```hcl
terraform {
  required_providers {
    docker = { source = "kreuzwerker/docker", version = "~> 3.0" }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:1.27"
}

resource "docker_container" "web" {
  name  = "web"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 8081
  }
}
```

- [ ] `curl localhost:8081`.
- [ ] Ajouter un réseau Docker et un second conteneur.
- [ ] `data` source, `depends_on`, `lifecycle` (`create_before_destroy`, `prevent_destroy`, `ignore_changes`).

## Jour 5 : le state

```bash
terraform state list
terraform state show docker_container.web
terraform state mv docker_container.web docker_container.frontend
terraform state rm docker_container.frontend
terraform import docker_container.frontend <id>
terraform show
terraform output -json
```

- [ ] Ouvrir `terraform.tfstate` et le lire.
- [ ] Supprimer une ressource du state puis la ré-importer.
- [ ] Bloc `moved { from = ... to = ... }` pour un renommage.

## Jour 6-7 : premier module

Structure :

```
modules/app/
├── main.tf
├── variables.tf
└── outputs.tf
main.tf   # appelle le module 2 fois
```

Exercice de fin : un module `app` qui crée un réseau Docker, un conteneur nginx paramétrable (nom, port, version) et expose `url` et `container_id`. L'appeler deux fois avec des paramètres différents.

## Checklist
- [ ] Je sais expliquer init / plan / apply et le rôle du state
- [ ] Je sais choisir entre count et for_each
- [ ] J'ai utilisé state mv / rm / import
- [ ] J'ai écrit et appelé un module
