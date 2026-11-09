# Phase 0 - Setup WSL (1 h)

## 1. Vérifier WSL2

Depuis PowerShell :

```powershell
wsl -l -v          # VERSION doit être 2
wsl --update
```

Distribution recommandée : Ubuntu 22.04 ou 24.04.

## 2. Limiter les ressources

Fichier `C:\Users\<toi>\.wslconfig` :

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

## 3. Activer systemd

Dans WSL, `/etc/wsl.conf` :

```ini
[boot]
systemd=true
```

Puis dans PowerShell : `wsl --shutdown`, et relancer Ubuntu.

## 4. Docker

### Option A : Docker Desktop (simple)
Installer Docker Desktop, puis Settings > Resources > WSL Integration > activer ton Ubuntu.

### Option B : Docker Engine dans WSL (plus léger)

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# fermer / rouvrir le terminal
docker run --rm hello-world
```

## 5. Outils

```bash
sudo apt update && sudo apt install -y git curl unzip make jq
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

mise use -g terraform kubectl kind helm k9s tflint kubectx kustomize
```

Autocomplétion et alias kubectl :

```bash
cat >> ~/.bashrc <<'EOT'
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
export KUBE_EDITOR=vim
EOT
source ~/.bashrc
```

## 6. Règle d'or

Travailler dans `~/lab`, **jamais** dans `/mnt/c/...` (I/O très lents, problèmes de permissions).

## 7. Test final

```bash
docker run --rm hello-world
terraform version
kind create cluster --name test && kubectl get nodes
kind delete cluster --name test
```

## Checklist
- [ ] WSL2 + systemd
- [ ] Docker fonctionne sans sudo
- [ ] terraform, kubectl, kind, helm, k9s installés
- [ ] Repo `~/lab` initialisé avec Git
- [ ] kind crée et détruit un cluster
