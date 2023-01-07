terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
    }
  }
  required_version = ">= 1.1.7"
}
