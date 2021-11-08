variable "LICENSE_FILE_PATH" {
  default  = "../license.hclic"
  description = "The Consul TCP listener configured to listen on a TCP address/port."
}

variable "HELM_CONSUL_VALUE_PATH" {
  default  = "../minimal-consul-ent-values.yaml"
  description = "Path to value fiel for Consul helm"
}

variable "HELM_PROMETHEUS_VALUE_PATH" {
  default  = "../monitoring/prometheus-values.yaml"
  description = "Path to value fiel for Prometheus helm"
}

variable "HELM_GRAFANA_VALUE_PATH" {
  default  = "../monitoring/grafana-values.yaml"
  description = "Path to value fiel for Grafana helm"
}

variable "SERVER_STORAGE" {
  default = "10Gi"
  description = "Consul Server storage size"
}

variable "HOST_PATH1" {
  default = "/tmp/consul/volumes/consul-0"
  description = "Server 1 storage host path"
}

variable "HOST_PATH2" {
  default = "/tmp/consul/volumes/consul-1"
  description = "Server 2 storage host path"
}

variable "HOST_PATH3" {
  default = "/tmp/consul/volumes/consul-2"
  description = "Server 3 storage host path"
}

# obtain a new one for each new deployment with command consul keygen
variable "GOSSIP_KEY" {
  default = "+cvMRNZv+TxRE0sZfnD3L97YeACl/W2e0kRaWxWT64Q="
  description = "Gossip protocol encryption key"
}

