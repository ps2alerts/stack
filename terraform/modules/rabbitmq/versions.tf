terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    rabbitmq = {
      source = "terraform-providers/rabbitmq"
    }
  }
  required_version = ">= 0.13"
}
