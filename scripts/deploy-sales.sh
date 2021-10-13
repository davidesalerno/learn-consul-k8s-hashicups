#!/bin/bash

kubectl create namespace sales --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f ./hashicups-ent/sales/ -n sales
kubectl apply -f ./crds-ent/sales/ -n sales
kubectl apply -f ./crds-ent/ingress/sales.yaml
