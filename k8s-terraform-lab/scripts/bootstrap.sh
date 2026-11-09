#!/usr/bin/env bash
set -euo pipefail

echo "==> Installation de mise"
if ! command -v mise >/dev/null; then
  curl https://mise.run | sh
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "==> Installation des outils"
mise use -g terraform kubectl kind helm k9s tflint kubectx kustomize

echo "==> Arborescence"
mkdir -p 01-terraform-basics 02-k8s-basics 03-k8s-advanced \
         04-terraform-k8s/cluster 04-terraform-k8s/workloads 04-terraform-k8s/modules \
         05-pipeline

[ -d .git ] || git init

echo "==> Vérifications"
docker version --format '{{.Server.Version}}' || echo "Docker non accessible, voir docs/00-setup-wsl.md"
terraform version | head -1
kubectl version --client | head -1
kind version
echo "OK"
