resource datadog_monitor "mongodb_high_cpu" {
  name = "PS2Alerts DB high CPU"
  type = "metric alert"
  query = "avg(last_15m):avg:kubernetes.cpu.usage.total{kube_container_name:ps2alerts-db} > 225000000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Mongo", description: "high CPU"})

  thresholds = {
    critical = 225000000 # 0.225 cores
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Mongo"}))
}

resource datadog_monitor "mongodb_high_mem" {
  name = "PS2Alerts DB high memory"
  type = "metric alert"
  query = "avg(last_5m):avg:kubernetes.memory.rss{kube_container_name:ps2alerts-db} > 996147000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Mongo", description: "high memory"})

  thresholds = {
    critical = 996147000 # 950MB
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Mongo"}))
}
