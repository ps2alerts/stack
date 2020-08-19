resource "kubernetes_persistent_volume_claim" "ps2alerts_database_volume" {
  metadata {
    name = "ps2alerts-redis"
    namespace = var.namespace
    labels = {
      app = "ps2alerts"
      environment = var.environment
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "do-block-storage"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "helm_release" "ps2alerts_redis" {
  name = var.redis_identifier
  repository = "https://charts.bitnami.com/bitnami"
  chart = "redis"
  namespace = var.namespace
  version = "10.7.16"

  values = [
    file("${path.module}/redis-values.yaml")
  ]

  set {
    name = "password"
    value = var.redis_pass
  }

  set {
    name = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.ps2alerts_database_volume.metadata[0].name
  }
}