#!/bin/bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm install -f prometheus-values.yaml prometheus prometheus-community/prometheus --version "14.9.2" --wait
helm install -f grafana-values.yaml grafana grafana/grafana --version "6.16.13" --wait