terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.2.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}


provider "kind" {}

resource "kind_cluster" "default" {
  name = "test-cluster"
  node_image = "kindest/node:v1.24.0"
  wait_for_ready = true
  
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}

provider "helm" {
  kubernetes {
    host = "${kind_cluster.default.endpoint}"
    cluster_ca_certificate = "${kind_cluster.default.cluster_ca_certificate}"
    client_certificate = "${kind_cluster.default.client_certificate}"
    client_key = "${kind_cluster.default.client_key}"
  }
}

resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "4.9.7"
  create_namespace = true

  values = [
    file("argocd/application.yaml")
  ]
}
