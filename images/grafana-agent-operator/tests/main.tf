terraform {
  required_providers {
    oci       = { source = "chainguard-dev/oci" }
    imagetest = { source = "chainguard-dev/imagetest" }
  }
}

variable "target_repository" {}

variable "digest" {
  description = "The image digest to run tests over."
}

locals { parsed = provider::oci::parse(var.digest) }

data "imagetest_inventory" "this" {}

module "cluster_harness" {
  source = "../../../tflib/imagetest/harnesses/k3s/"

  inventory         = data.imagetest_inventory.this
  name              = basename(path.module)
  target_repository = var.target_repository
  cwd               = path.module
}

module "helm" {
  source = "../../../tflib/imagetest/helm"

  name      = "grafana-agent-operator"
  repo      = "https://grafana.github.io/helm-charts"
  chart     = "grafana-agent-operator"
  namespace = "grafana-agent-operator"

  values = {
    image = {
      registry   = local.parsed.registry
      repository = local.parsed.repo
      tag        = local.parsed.pseudo_tag
    }
  }
}

resource "imagetest_feature" "basic" {
  name        = "basic"
  description = "Basic installation"
  harness     = module.cluster_harness.harness

  steps = [
    {
      name = "Helm Install"
      cmd  = module.helm.install_cmd
    }
  ]

  labels = {
    type = "k8s"
  }
}

resource "imagetest_harness_docker" "docker" {
  name      = "docker"
  inventory = data.imagetest_inventory.this
}

resource "imagetest_feature" "image" {
  name        = "image"
  description = "Basic image test"
  harness     = imagetest_harness_docker.docker

  steps = [
    {
      name = "-help"
      cmd  = "docker run --rm ${var.digest} -help"
    },
    {
      name = "-version"
      cmd  = "docker run --rm ${var.digest} -version"
    },
  ]

  labels = {
    type = "container"
  }
}