#!/bin/bash

kubectl create namespace crm --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f ./hashicups-ent/crm/ -n crm
kubectl apply -f ./crds-ent/crm/ -n crm
kubectl apply -f ./crds-ent/ingress/crm.yaml