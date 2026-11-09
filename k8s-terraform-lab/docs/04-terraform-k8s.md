# Phase 4 - Terraform + Kubernetes (2 semaines)

Dossier : `04-terraform-k8s/`

```
04-terraform-k8s/
├── cluster/      # state 1 : le cluster kind
├── workloads/    # state 2 : ce qui tourne dedans
└── modules/
    └── k8s-app/
```

**Pourquoi deux states ?** Les providers `kubernetes` et `helm` ont besoin du cluster **au moment du plan**. Si le cluster est créé dans le même apply, le plan échoue ou se comporte mal. On sépare donc l'infra (cluster) et les workloads.

## Étape 1 : le cluster avec Terraform

`cluster/main.tf` :

```hcl
terraform {
  required_providers {
    kind = { source = "tehcyx/kind", version = "~> 0.6" }
  }
}

resource "kind_cluster" "this" {
  name            = "lab-tf"
  wait_for_ready  = true
  kubeconfig_path = pathexpand("~/.kube/lab-tf.config")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 8080
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 8443
      }
    }
    node { role = "worker" }
    node { role = "worker" }
  }
}

output "kubeconfig_path" {
  value = kind_cluster.this.kubeconfig_path
}
```

```bash
cd cluster && terraform init && terraform apply
KUBECONFIG=~/.kube/lab-tf.config kubectl get nodes
```

- [ ] Cluster créé et détruit par Terraform.

## Étape 2 : providers kubernetes et helm

`workloads/providers.tf` :

```hcl
terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.14" }
  }
}

variable "kubeconfig" {
  type    = string
  default = "~/.kube/lab-tf.config"
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig)
  }
}
```

(Si la syntaxe du provider helm a changé dans la version que tu installes, consulte sa doc : les versions 3.x ont modifié le bloc `kubernetes`.)

- [ ] Créer un namespace avec `kubernetes_namespace`.
- [ ] Un deployment avec `kubernetes_deployment_v1` (et constater la verbosité).

## Étape 3 : composants via Helm

```hcl
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [yamlencode({
    controller = {
      hostPort     = { enabled = true }
      service      = { type = "NodePort" }
      nodeSelector = { "ingress-ready" = "true" }
      tolerations = [{
        key = "node-role.kubernetes.io/control-plane", operator = "Equal", effect = "NoSchedule"
      }]
      publishService = { enabled = false }
    }
  })]
}
```

- [ ] ingress-nginx
- [ ] metrics-server (`--kubelet-insecure-tls`)
- [ ] cert-manager (`installCRDs = true`)
- [ ] kube-prometheus-stack (optionnel, gourmand en RAM)

## Étape 4 : module réutilisable "k8s-app"

Entrées : `name`, `image`, `replicas`, `port`, `host`, `env` (map), `namespace`.
Ressources : Deployment, Service, Ingress, ConfigMap.
Sorties : `url`, `service_name`.

- [ ] Appeler le module 2 fois (deux apps).
- [ ] `for_each` sur une map d'apps pour les générer toutes.
- [ ] Tester : `curl -H "Host: app1.local" localhost:8080`.

## Étape 5 : ArgoCD via Terraform

```hcl
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
}
```

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
kubectl -n argocd port-forward svc/argocd-server 8443:443
```

- [ ] Installer ArgoCD.
- [ ] Créer une `Application` pointant sur un repo Git avec des manifestes.
- [ ] Modifier le repo, observer la synchro. Modifier à la main dans le cluster, observer le drift / self-heal.
- [ ] Répartition : Terraform pour l'infra et les composants de plateforme, ArgoCD pour les apps.

## Pièges à comprendre
- Cycle cluster -> providers dans un seul state.
- `helm_release` qui reste en `failed` : `terraform taint` ou `helm uninstall`.
- CRDs et ressources `kubernetes_manifest` : la CRD doit exister avant le plan.
- `destroy` : supprimer d'abord les workloads, puis le cluster.

## Checklist
- [ ] Cluster kind géré par Terraform
- [ ] Deux states séparés, je sais expliquer pourquoi
- [ ] ingress-nginx + metrics-server + cert-manager installés par Terraform
- [ ] Module k8s-app réutilisé
- [ ] ArgoCD déploie une app depuis Git
- [ ] `make down && make up` reconstruit tout
