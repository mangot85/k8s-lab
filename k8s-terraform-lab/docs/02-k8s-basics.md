# Phase 2 - Kubernetes fondamentaux (2 semaines)

Dossier : `02-k8s-basics/`. Cluster : `make up`.

**Règle** : YAML à la main. Pour générer un squelette :

```bash
kubectl create deployment web --image=nginx:1.27 --dry-run=client -o yaml > deploy.yaml
kubectl explain deployment.spec.strategy
```

## Semaine 1

### 1. Pods, ReplicaSets, Deployments
- [ ] Pod nginx en YAML, `kubectl apply`, `describe`, `logs`, `exec`.
- [ ] Deployment 3 replicas.
- [ ] Rolling update : changer l'image, `kubectl rollout status`.
- [ ] Rollback : `kubectl rollout undo`, `kubectl rollout history`.
- [ ] Tuer un pod, observer le ReplicaSet le recréer.
- [ ] Stratégie : `maxSurge`, `maxUnavailable`.

### 2. Services
- [ ] ClusterIP : accès depuis un autre pod (`kubectl run tmp --rm -it --image=busybox -- wget -qO- web`).
- [ ] NodePort.
- [ ] DNS interne : `web.<ns>.svc.cluster.local`.
- [ ] `kubectl get endpoints` : comprendre le lien selector / labels.

### 3. ConfigMaps et Secrets
- [ ] ConfigMap en variables d'env et en volume.
- [ ] Secret (base64, pas du chiffrement !).
- [ ] Modifier une ConfigMap : qu'est-ce qui se met à jour tout seul ?

### 4. Probes et ressources
- [ ] `livenessProbe`, `readinessProbe`, `startupProbe`.
- [ ] `requests` / `limits`, comprendre les QoS classes (Guaranteed, Burstable, BestEffort).

## Semaine 2

### 5. Organisation et scheduling
- [ ] Namespaces, `kubectl config set-context --current --namespace=...`.
- [ ] Labels, selectors, annotations.
- [ ] `nodeSelector`, taints / tolerations, `nodeAffinity`, `podAntiAffinity`.

### 6. Ingress

```bash
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller --timeout=90s
```

- [ ] Deux apps derrière un Ingress avec routage par chemin.
- [ ] Routage par host : `curl -H "Host: app.local" localhost:8080`.

### 7. Jobs et stockage
- [ ] Job, CronJob.
- [ ] PVC + StatefulSet (ex. postgres), supprimer le pod, vérifier la persistance.
- [ ] StorageClass par défaut de kind.

## Exercices de debug (essentiels)

Casse volontairement, puis diagnostique avec `describe`, `logs`, `events`, `k9s` :

- [ ] Image inexistante -> `ImagePullBackOff`
- [ ] Commande qui plante -> `CrashLoopBackOff`
- [ ] Probe readiness qui échoue -> pod jamais Ready
- [ ] Limite mémoire trop basse -> `OOMKilled`
- [ ] Selector de Service avec une faute -> endpoints vides
- [ ] Requests supérieures à la capacité -> pod `Pending`
- [ ] Taint sans toleration -> `Pending`

```bash
kubectl get events --sort-by=.lastTimestamp
kubectl describe pod <pod>
kubectl logs <pod> --previous
kubectl port-forward svc/web 8080:80
kubectl debug -it <pod> --image=busybox --target=<container>
```

## Checklist
- [ ] Je sais écrire Deployment / Service / Ingress sans copier
- [ ] Je diagnostique les 7 pannes ci-dessus
- [ ] Je comprends le chemin : client -> Ingress -> Service -> Pod
