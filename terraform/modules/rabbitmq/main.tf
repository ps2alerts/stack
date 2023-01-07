locals {
  hostname = "queues-temp.ps2alerts.com"
  events = toset(["Death", "FacilityControl", "GainExperience", "VehicleDestroy"])
  arguments = <<EOF
{
  "x-message-ttl": 300000
}
EOF
}

provider "rabbitmq" {
  endpoint = join("://", ["https", local.hostname])
  username = "admin"
  password = var.rabbitmq_admin_pass
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
    name = "ingress.hostname"
    value = local.hostname
  }
}

resource "time_sleep" "wait" {
  depends_on = [helm_release.ps2alerts_rabbitmq]
  create_duration = "30s"
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

resource "rabbitmq_exchange" "ps2alerts_census" {
  name  = "ps2alerts-census"
  depends_on = [time_sleep.wait]
  vhost = rabbitmq_permissions.ps2alerts.vhost

  settings {
    type        = "fanout"
    durable     = false
    auto_delete = false
  }
}

resource "rabbitmq_exchange" "ps2alerts_topic" {
  name  = "ps2alerts-topic"
  depends_on = [time_sleep.wait]
  vhost = rabbitmq_permissions.ps2alerts.vhost

  settings {
    type        = "topic"
    durable     = true
    auto_delete = false
  }
}
resource "rabbitmq_binding" "ps2alerts_collector_topic" {
  source           = rabbitmq_exchange.ps2alerts_census.name
  vhost            = rabbitmq_permissions.ps2alerts.vhost
  destination      = rabbitmq_exchange.ps2alerts_topic.name
  destination_type = "exchange"
}

resource "rabbitmq_queue" "ps2alerts_census_world_1_events" {
  for_each = local.events
  name = "census-1-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}
resource "rabbitmq_queue" "ps2alerts_census_world_10_events" {
  for_each = local.events
  name = "census-10-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}
resource "rabbitmq_queue" "ps2alerts_census_world_13_events" {
  for_each = local.events
  name = "census-13-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}
resource "rabbitmq_queue" "ps2alerts_census_world_17_events" {
  for_each = local.events
  name = "census-17-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}
resource "rabbitmq_queue" "ps2alerts_census_world_19_events" {
  for_each = local.events
  name = "census-19-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}
resource "rabbitmq_queue" "ps2alerts_census_world_1000_events" {
  for_each = local.events
  name = "census-1000-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}
resource "rabbitmq_queue" "ps2alerts_census_world_2000_events" {
  for_each = local.events
  name = "census-2000-${each.key}"
  vhost = rabbitmq_vhost.ps2alerts.name
  settings {
    durable = false
    arguments_json = "${local.arguments}"
  }
}

// Bindings
resource "rabbitmq_binding" "ps2alerts_census_world_1_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_1_events]
  for_each         = local.events
  routing_key      = "1.${each.key}.*"
  destination      = "census-1-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}
resource "rabbitmq_binding" "ps2alerts_census_world_10_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_10_events]
  for_each         = local.events
  routing_key      = "10.${each.key}.*"
  destination      = "census-10-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}
resource "rabbitmq_binding" "ps2alerts_census_world_13_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_13_events]
  for_each         = local.events
  routing_key      = "13.${each.key}.*"
  destination      = "census-13-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}
resource "rabbitmq_binding" "ps2alerts_census_world_17_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_17_events]
  for_each         = local.events
  routing_key      = "17.${each.key}.*"
  destination      = "census-17-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}
resource "rabbitmq_binding" "ps2alerts_census_world_19_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_19_events]
  for_each         = local.events
  routing_key      = "19.${each.key}.*"
  destination      = "census-19-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}
resource "rabbitmq_binding" "ps2alerts_census_world_1000_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_1000_events]
  for_each         = local.events
  routing_key      = "1000.${each.key}.*"
  destination      = "census-1000-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}
resource "rabbitmq_binding" "ps2alerts_census_world_2000_bindings" {
  depends_on = [rabbitmq_queue.ps2alerts_census_world_2000_events]
  for_each         = local.events
  routing_key      = "2000.${each.key}.*"
  destination      = "census-2000-${each.key}"
  destination_type = "queue"
  source           = rabbitmq_exchange.ps2alerts_topic.name
  vhost            = rabbitmq_vhost.ps2alerts.name
}

