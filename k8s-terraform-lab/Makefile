CLUSTER ?= lab

.PHONY: up down reset ingress nodes calico-up fmt

up:
	kind create cluster --name $(CLUSTER) --config kind/kind-config.yaml
	kubectl cluster-info --context kind-$(CLUSTER)

down:
	kind delete cluster --name $(CLUSTER)

reset: down up

nodes:
	kubectl get nodes -o wide

# Cluster sans CNI par défaut + Calico (NetworkPolicies actives)
calico-up:
	kind create cluster --name $(CLUSTER) --config kind/kind-config-calico.yaml
	kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
	@echo "Vérifie la dernière version de Calico si l'URL ne répond plus."

fmt:
	terraform fmt -recursive
