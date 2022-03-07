locals {
  hostname = "messages.ps2alerts.com"
}

provider "rabbitmq" {
  endpoint = join("://", ["https", local.hostname])
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
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "helm_release" "ps2alerts_rabbitmq" {
  name       = var.identifier
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "8.30.0"

  values = [
    file("${path.module}/rabbitmq-values.yaml")
  ]

  set {
    name  = "auth.password"
    value = var.rabbitmq_admin_pass
  }

  set {
    name  = "auth.erlangCookie"
    value = var.rabbitmq_erlang_cookie
  }

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.ps2alerts_rabbitmq_volume_claim.metadata[0].name
  }

  set {
    name = "ingress.hostname"
    value = local.hostname
  }
}

resource "time_sleep" "wait" {
  depends_on = [helm_release.ps2alerts_rabbitmq]
  create_duration = "10s"
}

resource "rabbitmq_vhost" "ps2alerts" {
  name = "ps2alerts"
  depends_on = [time_sleep.wait]
}

resource "rabbitmq_user" "ps2alerts" {
  name     = "ps2alerts"
  depends_on = [time_sleep.wait]
  password = var.rabbitmq_ps2alerts_pass
  tags     = ["monitoring"]
}

resource "rabbitmq_permissions" "ps2alerts" {
  depends_on = [time_sleep.wait]
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
  depends_on = [time_sleep.wait]
  vhost = rabbitmq_permissions.ps2alerts.vhost

  settings {
    type        = "direct"
    durable     = true
    auto_delete = false
  }
}
