# Cheatsheet

## Terraform
```bash
terraform init -upgrade
terraform plan -out=tfplan && terraform apply tfplan
terraform apply -target=<ressource>
terraform apply -replace=<ressource>
terraform destroy
terraform fmt -recursive
terraform state list | show | mv | rm
terraform import <addr> <id>
terraform output -json
terraform console
TF_LOG=DEBUG terraform plan
```

## kubectl
```bash
kubectl get pods -A -o wide
kubectl get all -n <ns>
kubectl describe <type> <nom>
kubectl logs <pod> [-c container] [-f] [--previous]
kubectl exec -it <pod> -- sh
kubectl apply -f . ; kubectl delete -f .
kubectl diff -f deploy.yaml
kubectl explain pod.spec.containers --recursive
kubectl get events --sort-by=.lastTimestamp
kubectl rollout status|history|undo deploy/<nom>
kubectl scale deploy/<nom> --replicas=3
kubectl top pods
kubectl port-forward svc/<nom> 8080:80
kubectl auth can-i <verbe> <ressource> --as=<user>
kubectl config get-contexts ; kubectl config use-context <ctx>
kubectl run tmp --rm -it --image=busybox -- sh
kubectl get pod <p> -o jsonpath='{.status.podIP}'
kubectl api-resources
```

## kind
```bash
kind create cluster --name lab --config kind/kind-config.yaml
kind get clusters
kind load docker-image monimage:tag --name lab
kind export kubeconfig --name lab
kind delete cluster --name lab
```

## Helm
```bash
helm repo add|update ; helm search repo <mot>
helm install|upgrade --install <rel> <chart> -n <ns> -f values.yaml
helm list -A ; helm history <rel> ; helm rollback <rel> <rev>
helm template|lint|show values
```

## Docker
```bash
docker ps ; docker logs -f <c> ; docker exec -it <c> sh
docker system prune -a      # nettoie tout (attention)
```

## Problèmes fréquents WSL
| Symptôme | Piste |
|----------|-------|
| Tout est lent | Projet dans `/mnt/c` -> déplacer dans `~/` |
| WSL consomme toute la RAM | `.wslconfig` (memory=) puis `wsl --shutdown` |
| `docker: permission denied` | `sudo usermod -aG docker $USER` puis relancer le terminal |
| kind : too many open files | `sudo sysctl fs.inotify.max_user_watches=524288` et `fs.inotify.max_user_instances=512` |
| Port 8080 déjà pris | Changer `hostPort` dans la config kind |
| Heure décalée après veille | `sudo hwclock -s` |
