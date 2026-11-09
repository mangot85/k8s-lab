# Phase 6 - Cloud réel (optionnel)

À faire seulement quand les phases 1 à 5 sont acquises.

## Avant de commencer
1. **Alerte budget** configurée (AWS Budgets / Azure Cost Management / GCP Budgets).
2. Utilisateur / identité dédiée au lab avec droits limités.
3. Habitude : `terraform destroy` **à chaque fin de session**.
4. Vérifier les tarifs actuels (le control plane managé et le NAT Gateway coûtent même sans charge).

## Exercice
Refaire la phase 4 sur EKS, AKS ou GKE :
- [ ] Réseau : VPC / VNet, subnets, NAT.
- [ ] IAM / identités (IRSA sur EKS, Workload Identity sur AKS / GKE).
- [ ] Cluster managé + node pool.
- [ ] Ingress / load balancer cloud, DNS.
- [ ] State distant sur le stockage du cloud (S3 + verrouillage, Azure Blob, GCS).
- [ ] Même module `k8s-app` : qu'est-ce qui change ?

## Alternative gratuite
LocalStack pour simuler une partie d'AWS en local (certaines fonctions, dont EKS, peuvent être limitées selon l'édition : vérifier la doc).

## Pistes ensuite
- Crossplane, Cluster API
- Policy as code : OPA Gatekeeper / Kyverno
- Service mesh : Linkerd ou Istio
- Certifications : Terraform Associate, CKA, CKAD
