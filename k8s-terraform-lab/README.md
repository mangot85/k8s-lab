# Lab Kubernetes + Terraform (WSL2)

Parcours structuré d'environ 9 à 10 semaines, 100 % local (kind + Docker), sans facture cloud.

## Progression

| Phase | Doc | Durée | Objectif |
|-------|-----|-------|----------|
| 0 | [Setup WSL](docs/00-setup-wsl.md) | 1 h | Environnement prêt |
| 1 | [Terraform basics](docs/01-terraform-basics.md) | 1 semaine | Langage, state, modules |
| 2 | [K8s fondamentaux](docs/02-k8s-basics.md) | 2 semaines | Objets de base, debug |
| 3 | [K8s avancé](docs/03-k8s-advanced.md) | 2 semaines | Helm, RBAC, réseau, observabilité |
| 4 | [Terraform + K8s](docs/04-terraform-k8s.md) | 2 semaines | IaC du cluster et des workloads |
| 5 | [Pratiques pro](docs/05-pro-practices.md) | 2 semaines | State distant, CI, sécurité, tests |
| 6 | [Cloud réel](docs/06-cloud.md) | optionnel | EKS / AKS / GKE |
| - | [Cheatsheet](docs/cheatsheet.md) | - | Commandes utiles |

## Démarrage rapide

```bash
git clone <ton-repo> ~/lab && cd ~/lab
./scripts/bootstrap.sh     # installe les outils, crée l'arborescence
make up                    # crée le cluster kind
make down                  # le détruit
```

## Règles du lab

1. Travailler dans `~/` (filesystem Linux), jamais dans `/mnt/c/`.
2. Tout est dans Git, commit à chaque exercice terminé.
3. Détruire et reconstruire souvent. Si ce n'est pas reproductible en une commande, ce n'est pas fini.
4. YAML écrit à la main. `kubectl create ... --dry-run=client -o yaml` uniquement pour générer un squelette.
5. Casser volontairement des choses, puis diagnostiquer.

## Suivi

Coche au fur et à mesure dans chaque doc. Note ce qui t'a bloqué dans `NOTES.md`.
