# Demo application for learning Consul on Kubernetes

This repository contains

To deploy the app run the following scripts in order. This assumes you have a
Kubernetes cluster available. This repository has been tested with Minikube and Kind.

## Download Official Consul Helm chart

`helm repo add hashicorp https://helm.releases.hashicorp.com`

## Minimal Consul install

`helm install -f minimal-consul-values.yaml consul hashicorp/consul --wait`

## Deploy example workload

`kubectl apply -f app`

## View application

`kubectl port-forward deploy/frontend 8080:80`

# Demo application for learning Consul Enterprise on Kubernetes

This repository contains

To deploy the app run the following scripts in order. This assumes you have a
Kubernetes cluster available. This repository has been tested with Minikube and Kind.

## Download Official Consul Helm chart

`helm repo add hashicorp https://helm.releases.hashicorp.com`

## Minimal Consul Enterprise install

### License
Grab a free trial licence from HashiCorp for Consul Enterprise here: https://www.hashicorp.com/products/consul/trial an put it in the license.hclic file.

`secret=$(cat license.hclic)`

`kubectl create namespace consul --dry-run=client -o yaml | kubectl apply -f -`

`kubectl create secret generic consul-ent-license --from-literal="key=${secret}" -n consul`

`kubectl create secret generic consul-gossip-encryption-key -n consul --from-literal=key=$(consul keygen)`

### Volume creation
In order to have got all the volumes for the Consul server instances you need to create the PV applying the yaml in k8s folder

`kubectl apply -f ./k8s/pv.yaml -n consul`

NOTE: You have to change the hostPath in this section of the `k8s/pv.yaml` file

```
  hostPath:
      path: /tmp/consul/volumes/consul-1 
```


### Install Consul via Helm
`helm install -n consul -f minimal-consul-ent-values.yaml consul hashicorp/consul --version "0.34.1" --wait`

## Deploy example workload 

`./scripts/deploy-sales.sh`

`./scripts/deploy-crm.sh`


## View applications

### Sales
Use this port forward

`kubectl port-forward service/consul-sales-ingress 8080:8080 --address 0.0.0.0 -n consul`

and then browse http://frontend.ingress.sales.dc1.consul:8080/ui/

### CRM
Use this port forward

`kubectl port-forward service/consul-crm-ingress 8081:8080 --address 0.0.0.0 -n consul`

and then browse http://frontend.ingress.crm.dc1.consul:8081/ui/

## Consul UI
Use this port forward

 `kubectl port-forward service/consul-server 8501 --address 0.0.0.0 -n consul`
 
and then browse http://localhost:8501