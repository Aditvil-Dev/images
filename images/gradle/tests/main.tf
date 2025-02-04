variable "digest" {
  description = "The image digest to run tests over."
}

variable "java-version" {
  description = "Java version"
}

variable "target_repository" {}

module "bash_sandbox" {
  source            = "../../../tflib/imagetest/sandboxes/bash"
  target_repository = var.target_repository
}

module "dind_test" {
  source = "../../../tflib/imagetest/tests/docker-in-docker"

  images = { gradle = var.digest }

  tests = [
    {
      name    = "smoke test"
      image   = module.bash_sandbox.image_ref
      content = [{ source = path.module }]
      cmd     = "./test.sh"
      envs = {
        JAVA_VERSION = var.java-version
      }
    }
  ]
}

