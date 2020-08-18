resource "kubernetes_service" "ps2alerts_redis_service" {
  metadata {
    name = "ps2alerts-redis"
    namespace = var.namespace
    labels = {
      app = var.redis_identifier
      environment = var.environment
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = var.redis_identifier
      environment = var.environment
    }
    port {
      port = var.redis_port
      target_port = var.redis_port
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ps2alerts_redis_volume" {
  metadata {
    name = var.redis_identifier
    namespace = var.namespace
    labels = {
      app = var.redis_identifier
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

resource "kubernetes_deployment" "ps2alerts_redis_deployment" {
  metadata {
    name = var.redis_identifier
    namespace = var.namespace
    labels = {
      app = var.redis_identifier
      environment = var.environment
    }
  }
  spec {
    replicas = 1
    revision_history_limit = 1
    selector {
      match_labels = {
        app = var.redis_identifier
        environment = var.environment
      }
    }
    template {
      metadata {
        labels = {
          app = var.redis_identifier
          environment = var.environment
        }
      }
      spec {
        container {
          name = var.redis_identifier
          image = "bitnami/redis:6.0"
          volume_mount {
            mount_path = "/bitnami/redis/data"
            name = kubernetes_persistent_volume_claim.ps2alerts_redis_volume.metadata[0].name
          }
          resources {
            limits {
              cpu = "100m"
              memory = "256Mi"
            }
            requests {
              cpu = "50m"
              memory = "128Mi"
            }
          }
          port {
            container_port = var.redis_port
          }
          env {
            name = "REDIS_PASSWORD"
            value = var.redis_pass
          }
        }
        volume {
          name = kubernetes_persistent_volume_claim.ps2alerts_redis_volume.metadata[0].name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ps2alerts_redis_volume.metadata[0].name
          }
        }
      }
    }
  }
}
