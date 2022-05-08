resource "kubernetes_persistent_volume_claim" "ps2alerts_redis_volume" {
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
    storage_class_name = "csi-cinder-classic"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "helm_release" "ps2alerts_redis" {
  name       = var.identifier
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "16.9.0"

  values = [
    file("${path.module}/redis-values.yaml")
  ]

  set {
    name  = "auth.password"
    value = var.redis_pass
  }

  set {
    name  = "master.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.ps2alerts_redis_volume.metadata[0].name
  }
}
