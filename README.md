# Demo application for learning Consul Enterprise on Kubernetes

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


## View applications

### Sales
Use this port forward

`kubectl port-forward service/consul-sales-ingress 8080:8080 --address 0.0.0.0 -n consul`

and then browse http://frontend.ingress.sales.dc1.consul:8080/ui/

## Architecture overview

The below diagram is summarizing the architecture of the Enterprise example.

![Enterprise Architecture diagram](docs/ent/img/diagram.png "Enterprise Architecture diagram")


## Consul UI
Use this port forward

 `kubectl port-forward service/consul-server 8501 --address 0.0.0.0 -n consul`
 
and then browse http://localhost:8501

## Useful info for the Request Timeout issue

1. The Order API is particularly slow (it takes more than 15 seconds to provide a response)
2. The Frontend service has got the Order API as an upstream service
3. The Frontend service is exposed outside the mesh through the Sales Ingress Gateway

If you perform a call to the Ingress gateway to have a response from the frontend service (i.e. curl http://frontend.ingress.sales.dc1.consul:8080/) you will get a "504 - Gateway timeout".
