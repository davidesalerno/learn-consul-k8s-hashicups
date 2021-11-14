#!/bin/bash

set -e
cd $(dirname $0)/..

if [ "$1" = "s1" ]; then
    git checkout rp-demo-step-1 hashicups-ent/apps/order-api.yaml
    kubectl apply -f hashicups-ent/apps/order-api.yaml -n apps
elif [ "$1" = "s2" ]; then
    git checkout HEAD --  hashicups-ent/apps/order-api.yaml
    kubectl apply -f hashicups-ent/apps/order-api.yaml -n apps
elif [ "$1" = "s3" ]; then
    git checkout rp-demo-step-2 hashicups-ent/apps/product-api.yaml
    git checkout rp-demo-step-2 crds-ent/apps/service-router.yaml
    kubectl apply -f hashicups-ent/apps/product-api.yaml -n apps
    kubectl apply -f crds-ent/apps/service-router.yaml -n apps
elif [ "$1" = "s4" ]; then
    git checkout rp-demo-step-3 crds-ent/apps/service-router.yaml
    kubectl apply -f crds-ent/apps/service-router.yaml -n apps
elif [ "$1" = "s5" ]; then
    git checkout HEAD -- hashicups-ent/apps/product-api.yaml
    kubectl apply -f hashicups-ent/apps/product-api.yaml -n apps
    kubectl delete -f crds-ent/apps/service-router.yaml -n apps
    git rm -f crds-ent/apps/service-router.yaml
else
    echo "Step not yet prepared"
fi