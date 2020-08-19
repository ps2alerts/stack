resource "kubernetes_persistent_volume_claim" "ps2alerts_rabbitmq_volume_claim" {
  metadata {
    name      = var.identifier
    namespace = var.namespace
    labels = {
      app         = "ps2alerts"
      environment = var.environment
    }
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "do-block-storage"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "helm_release" "ps2alerts_rabbitmq" {
  name       = var.identifier
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  namespace  = var.namespace

  values = [
    file("${path.module}/rabbitmq-values.yaml")
  ]

  set {
    name  = "auth.password"
    value = var.rabbitmq_auth_pass
  }

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.ps2alerts_rabbitmq_volume_claim.metadata[0].name
  }
}