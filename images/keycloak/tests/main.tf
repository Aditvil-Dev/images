terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
  }
}

variable "digest" {
  description = "The image digest to run tests over."
}

# Allows us to define the args passed to the helm chart test. We need to change
# these for the FIPS image, which also invokes this test.
variable "args" {
  description = "Args for the helm test"
  type        = list(string)
  default     = ["start-dev"]
}

# invoking '--help' instead of '--version' due to:
# - https://github.com/keycloak/keycloak/issues/23783
data "oci_exec_test" "help" {
  digest = var.digest
  script = "docker run --rm $IMAGE_NAME --help"
}
locals { parsed = provider::oci::parse(var.digest) }

# Run keycloak tests.
data "oci_exec_test" "keycloak-production-test" {
  digest = var.digest
  script = "${path.module}/keycloak-production-mode.sh"
}

# Run the keycloak-operator image tests with this image.
module "run-keycloak-tests" {
  source = "../../keycloak-operator/tests"
  # need to hardcode this for the time being to unblock the release of keylcoak operator and keycloak to version 25 which is not published yet
  # due to release failures
  digest         = "keycloak/keycloak-operator:25.0"
  keycloak-image = var.digest
}
