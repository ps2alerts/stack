resource datadog_monitor "rabbit_high_cpu" {
  name = "PS2Alerts Rabbit high CPU"
  type = "metric alert"
  query = "avg(last_15m):avg:kubernetes.cpu.usage.total{kube_container_name:ps2alerts-rabbitmq-0} > 500000000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Redis", description: "high CPU"})

  thresholds = {
    critical = 500000000 # 0.5 cores
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Rabbit"}))
}

resource datadog_monitor "rabbit_high_mem" {
  name = "PS2Alerts Rabbit high mem"
  type = "metric alert"
  query = "avg(last_5m):avg:kubernetes.memory.rss{kube_container_name:ps2alerts-rabbitmq-0} > 996147000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Redis", description: "high memory"})

  thresholds = {
    critical = 996147000 # 950MB
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Rabbit"}))
}