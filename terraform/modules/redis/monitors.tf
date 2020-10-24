resource datadog_monitor "redis_high_cpu" {
  name = "PS2Alerts Redis high CPU"
  type = "metric alert"
  query = "avg(last_15m):avg:kubernetes.cpu.usage.total{pod_name:ps2alerts-redis-master-0} > 40000000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Redis", description: "high CPU"})

  thresholds = {
    critical = 40000000 # 0.04 cores
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Redis"}))
}

resource datadog_monitor "redis_high_mem" {
  name = "PS2Alerts Redis high memory"
  type = "metric alert"
  query = "avg(last_5m):avg:kubernetes.memory.rss{pod_name:ps2alerts-redis-master-0} > 157286000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Redis", description: "high memory"})

  thresholds = {
    critical = 157286000 # 150MB
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Redis"}))
}
