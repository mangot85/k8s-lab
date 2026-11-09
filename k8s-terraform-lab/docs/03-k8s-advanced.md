# Phase 3 - Kubernetes avancé (2 semaines)

Dossier : `03-k8s-advanced/`.

## Helm
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx
helm install web bitnami/nginx -n demo --create-namespace
helm list -A
helm upgrade web bitnami/nginx --set replicaCount=3 -n demo
helm rollback web 1 -n demo
helm uninstall web -n demo
helm template web bitnami/nginx | less
```
- [ ] Installer, mettre à jour, rollback.
- [ ] `helm show values` et un `values.yaml` perso.
- [ ] `helm create mychart` : écrire ton propre chart (templates, `_helpers.tpl`, values).
- [ ] `helm lint`, `helm template`.

## Kustomize
```
base/            deployment.yaml service.yaml kustomization.yaml
overlays/dev/    kustomization.yaml (1 replica)
overlays/prod/   kustomization.yaml (3 replicas, ressources, patch)
```
```bash
kubectl kustomize overlays/prod
kubectl apply -k overlays/dev
```
- [ ] Overlay dev / prod avec patches (`patches`, `replicas`, `images`).

## RBAC
```bash
kubectl create sa dev -n demo
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n demo --dry-run=client -o yaml
kubectl auth can-i list pods -n demo --as=system:serviceaccount:demo:dev
```
- [ ] Role + RoleBinding pour un ServiceAccount.
- [ ] ClusterRole + ClusterRoleBinding.
- [ ] Tester avec `auth can-i`, constater les refus (403).
- [ ] Générer un kubeconfig restreint pour ce ServiceAccount.

## NetworkPolicies

Les policies ne sont pas appliquées avec le CNI par défaut de kind.

```bash
make down
make calico-up
kubectl get pods -n kube-system -w
```
- [ ] Policy `default-deny` dans un namespace.
- [ ] Autoriser uniquement frontend -> backend.
- [ ] Tester avec `wget` depuis différents pods.

## Autoscaling et quotas
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system \
  --set args={--kubelet-insecure-tls}
kubectl top nodes
```
- [ ] HPA sur CPU, générer de la charge (`kubectl run load --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://web; done"`).
- [ ] PodDisruptionBudget + `kubectl drain`.
- [ ] ResourceQuota et LimitRange dans un namespace.

## Observabilité
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```
- [ ] Ouvrir Grafana, explorer les dashboards.
- [ ] Écrire une requête PromQL (`rate(container_cpu_usage_seconds_total[5m])`).
- [ ] Créer une alerte simple.

## Checklist
- [ ] Chart Helm perso fonctionnel
- [ ] Overlays Kustomize dev / prod
- [ ] RBAC testé avec `can-i`
- [ ] NetworkPolicy qui bloque réellement
- [ ] HPA qui scale sous charge
- [ ] Grafana opérationnel
