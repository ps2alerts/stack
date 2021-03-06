terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
    }
    datadog = {
      source = "datadog/datadog"
    }
  }
  required_version = ">= 0.13"
}
