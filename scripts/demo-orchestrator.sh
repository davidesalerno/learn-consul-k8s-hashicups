#!/bin/bash

set -e
cd $(dirname $0)/..

if [ "$1" = "s1" ]; then
    git checkout rp-demo-step-1 hashicups-ent/apps/order-api.yaml
else  if [ "$1" = "s2" ]; then
    git checkout HEAD --  hashicups-ent/apps/order-api.yaml
else if [ "$1" = "s3" ]; then
    git checkout rp-demo-step-2 hashicups-ent/apps/order-api.yaml
else if [ "$1" = "s4" ]; then
    git checkout rp-demo-step-3 hashicups-ent/apps/order-api.yaml
else  if [ "$1" = "s5" ]; then
    git checkout HEAD --  hashicups-ent/apps/product-api.yaml
    git checkout HEAD --  crds-ent/apps/
else
    echo "Step not yet prepared"
fi