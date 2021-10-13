#!/bin/bash
# See https://learn.hashicorp.com/tutorials/consul/service-mesh-application-secure-networking
#     https://learn.hashicorp.com/tutorials/consul/kubernetes-secure-agents
#     https://www.consul.io/docs/k8s/operations/uninstall
#     https://learn.hashicorp.com/tutorials/consul/kubernetes-kind
#     https://www.hashicorp.com/products/consul/trial


secret=$(cat license.hclic)

kubectl create namespace consul --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic consul-ent-license --from-literal="key=${secret}" -n consul
kubectl create secret generic consul-gossip-encryption-key -n consul --from-literal=key=$(consul keygen)

kubectl apply -f ./k8s/pv.yaml -n consul

helm repo add hashicorp https://helm.releases.hashicorp.com

echo "Now you can run the commad"
echo "helm install -n consul -f minimal-consul-ent-values.yaml consul hashicorp/consul --version "0.34.1" --wait"
