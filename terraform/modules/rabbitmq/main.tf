provider "rabbitmq" {
  endpoint = "https://rabbit.ps2alerts.com"
  username = "admin"
  password = var.rabbitmq_admin_pass
}

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
    value = var.rabbitmq_admin_pass
  }

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.ps2alerts_rabbitmq_volume_claim.metadata[0].name
  }
}

resource "rabbitmq_vhost" "ps2alerts" {
  name = "ps2alerts"
}

resource "rabbitmq_user" "ps2alerts" {
  name     = "ps2alerts"
  password = var.rabbitmq_ps2alerts_pass
  tags     = ["monitoring"]
}

resource "rabbitmq_permissions" "ps2alerts" {
  user  = rabbitmq_user.ps2alerts.name
  vhost = rabbitmq_vhost.ps2alerts.name

  permissions {
    configure = ".*"
    write     = ".*"
    read      = ".*"
  }
}

resource "rabbitmq_exchange" "ps2alerts" {
  name  = "ps2alerts"
  vhost = rabbitmq_permissions.ps2alerts.vhost

  settings {
    type        = "direct"
    durable     = true
    auto_delete = false
  }
}

resource "rabbitmq_user" "datadog" {
  name     = "datadog"
  password = var.rabbitmq_datadog_pass
  tags     = ["datadog monitoring"]
}

resource "rabbitmq_permissions" "datadog" {
  user  = rabbitmq_user.datadog.name
  vhost = rabbitmq_vhost.ps2alerts.name

  permissions {
    configure = "^aliveness-test$"
    write     = "^amq\\.default$"
    read      = ".*"
  }
}