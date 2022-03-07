resource "kubernetes_service" "ps2alerts_database_service" {
  metadata {
    name      = "ps2alerts-db"
    namespace = var.namespace
    labels = {
      app         = var.db_identifier
      environment = var.environment
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app         = var.db_identifier
      environment = var.environment
    }
    port {
      port        = var.db_port
      target_port = var.db_port
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ps2alerts_database_volume" {
  metadata {
    name      = var.db_identifier
    namespace = var.namespace
    labels = {
      app         = var.db_identifier
      environment = var.environment
    }
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "30Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "ps2alerts_database_deployment" {
  metadata {
    name      = var.db_identifier
    namespace = var.namespace
    labels = {
      app         = var.db_identifier
      environment = var.environment
    }
  }
  spec {
    replicas               = 1
    revision_history_limit = 1
    selector {
      match_labels = {
        app         = var.db_identifier
        environment = var.environment
      }
    }
    template {
      metadata {
        labels = {
          app         = var.db_identifier
          environment = var.environment
        }
      }
      spec {
        container {
          name  = var.db_identifier
          image = "mongo:4.4.6"
          volume_mount {
            mount_path = "/data/db"
            name       = kubernetes_persistent_volume_claim.ps2alerts_database_volume.metadata[0].name
          }
          resources {
            requests = {
              cpu    = "400m"
              memory = "1.5Gi"
            }
            limits = {
              cpu    = "1500m"
              memory = "1.5Gi"
            }

          }
          port {
            container_port = var.db_port
          }
          env {
            name  = "MONGO_INITDB_DATABASE"
            value = "ps2alerts"
          }
          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = var.db_user
          }
          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = var.db_pass
          }
        }
        volume {
          name = kubernetes_persistent_volume_claim.ps2alerts_database_volume.metadata[0].name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ps2alerts_database_volume.metadata[0].name
          }
        }
      }
    }
  }
}
