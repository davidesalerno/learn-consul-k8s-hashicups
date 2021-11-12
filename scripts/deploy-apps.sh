#!/bin/bash

kubectl create namespace apps --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f ./hashicups-ent/apps/ -n apps
kubectl apply -f ./crds-ent/apps/ -n apps
kubectl apply -f ./crds-ent/ingress/apps.yaml
