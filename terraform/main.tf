terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.9"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.3.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.13.0"
    }
    external = {
      source = "hashicorp/external"
      version = "2.1.0"
    }
  }
}

provider "kind" {
  # Configuration options
}

resource "kind_cluster" "consul" {
    name = "consul"
    wait_for_ready = true
}

provider "kubernetes" {
  host = kind_cluster.consul.endpoint

  client_certificate     = kind_cluster.consul.client_certificate
  client_key             = kind_cluster.consul.client_key
  cluster_ca_certificate = kind_cluster.consul.cluster_ca_certificate
}

resource "kubernetes_namespace" "consul" {
  depends_on = [kind_cluster.consul]
  metadata {
    name = "consul"
  }
}

resource "kubernetes_namespace" "apps" {
  depends_on = [kind_cluster.consul]
  metadata {
    name = "apps"
  }
}

resource "kubernetes_namespace" "monitoring" {
  depends_on = [kind_cluster.consul]
  metadata {
    name = "monitoring"
  }
}
provider "external" {
}

data "external" "gossip-enc-key" {
  program = ["sh", "get-gossip-enc-key.sh"]
}


resource "kubernetes_secret" "consul-ent-license" {
  depends_on = [kubernetes_namespace.consul]
  metadata {
    name = "consul-ent-license"
    namespace = "consul"
  }
  data = {
    key = "${file(var.LICENSE_FILE_PATH)}"
  }
}

resource "kubernetes_secret" "consul-gossip-encryption-key" {
  depends_on = [kubernetes_namespace.consul]
  metadata {
    name = "consul-gossip-encryption-key"
    namespace = "consul"
  }
  data = {
    key = data.external.gossip-enc-key.result["key"]
  }
}

resource "kubernetes_persistent_volume" "pv-consul-0" {
  depends_on = [kubernetes_namespace.consul]
  metadata {
    name = "pv-consul-0"
    labels = {
      type = "local"
    }
  }
  spec {
    storage_class_name = "manual"
    capacity = {
      storage = var.SERVER_STORAGE
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    claim_ref {
      namespace = "consul"
      name = "data-consul-consul-server-0"
    }
    persistent_volume_source {
      host_path {
        path = var.HOST_PATH1
      }
    }
  }
}

provider "helm" {
  kubernetes {
    host = kind_cluster.consul.endpoint

    client_certificate     = kind_cluster.consul.client_certificate
    client_key             = kind_cluster.consul.client_key
    cluster_ca_certificate = kind_cluster.consul.cluster_ca_certificate
  }
}

resource "helm_release" "consul" {
  name       = "consul"
  depends_on = [ kubernetes_secret.consul-gossip-encryption-key, kubernetes_secret.consul-ent-license, kubernetes_persistent_volume.pv-consul-0 ]
  namespace  = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  values = [
    "${file(var.HELM_CONSUL_VALUE_PATH)}"
  ]
}


provider "kubectl" {
  host = kind_cluster.consul.endpoint

  client_certificate     = kind_cluster.consul.client_certificate
  client_key             = kind_cluster.consul.client_key
  cluster_ca_certificate = kind_cluster.consul.cluster_ca_certificate
}

data "kubectl_path_documents" "ms-manifests" {
    pattern = "../hashicups-ent/apps/*.yaml"
}

data "kubectl_path_documents" "crds-manifests" {
    pattern = "../crds-ent/apps/*.yaml"
}

data "kubectl_path_documents" "ingress-manifests" {
    pattern = "../crds-ent/ingress/*.yaml"
}

data "kubectl_path_documents" "global-manifests" {
    pattern = "../crds-ent/global/*.yaml"
}

resource "kubectl_manifest" "ms-apps" {
    depends_on = [kubernetes_namespace.apps, helm_release.consul ]
    for_each  = data.kubectl_path_documents.ms-manifests.manifests
    yaml_body = each.value
    override_namespace = "apps"
}

resource "kubectl_manifest" "crds-apps" {
    depends_on = [kubernetes_namespace.apps, helm_release.consul]
    for_each  = data.kubectl_path_documents.crds-manifests.manifests
    yaml_body = each.value
    override_namespace = "apps"
}

resource "kubectl_manifest" "ingress" {
    depends_on = [kubernetes_namespace.consul, kubectl_manifest.crds-apps, kubectl_manifest.ms-apps, helm_release.consul]
    for_each  = data.kubectl_path_documents.ingress-manifests.manifests
    yaml_body = each.value
}

resource "kubectl_manifest" "global" {
    depends_on = [kubernetes_namespace.consul, helm_release.consul]
    for_each  = data.kubectl_path_documents.global-manifests.manifests
    yaml_body = each.value
}


resource "helm_release" "prometheus" {
  name       = "prometheus"
  depends_on = [ kubernetes_namespace.monitoring, helm_release.consul]
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  values = [
    "${file(var.HELM_PROMETHEUS_VALUE_PATH)}"
  ]
}
resource "kubernetes_config_map" "grafana-dashboards" {
  depends_on = [ kubernetes_namespace.monitoring]
  metadata {
    name      = "grafana-dashboards-consul"
    namespace = "monitoring"

    labels = {
      grafana_dashboard = 1
    }

  }

  data = {
    "resiliency-dashboard.json"        = file("../monitoring/grafana/resiliency-dashboard.json")
  }
}


resource "helm_release" "grafana" {
  name       = "grafana"
  depends_on = [ kubernetes_namespace.monitoring, helm_release.consul, kubernetes_config_map.grafana-dashboards]
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  values = [
    "${file(var.HELM_GRAFANA_VALUE_PATH)}"
  ]
}
