resource datadog_monitor "mongodb_high_cpu" {
  name = "PS2Alerts DB high CPU"
  type = "metric alert"
  query = "avg(last_15m):avg:kubernetes.cpu.usage.total{kube_container_name:ps2alerts-db} > 450000000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Mongo", description: "high CPU"})

  thresholds = {
    critical = 450000000 # 0.45 cores
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

resource datadog_monitor "mongodb_online" {
  name = "PS2Alerts DB online"
  type = "metric alert"
  query = "max(last_1m):avg:kubernetes.containers.running{kube_service:ps2alerts-db} < 1"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {application: "PS2Alerts Mongo", description: "service offline"})

  thresholds = {
    critical = 1
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Mongo"}))
}

resource datadog_monitor "mongodb_restarts" {
  name = "PS2Alerts DB restarts"
  type = "query alert"
  query = "change(sum(last_5m),last_5m):avg:kubernetes.containers.restarts{deployment_name:ps2alerts-mongo} > 0.5"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {environment: var.environment, application: "PS2Alerts Mongo", description: "restarts"})

  thresholds = {
    critical = 0.5
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Mongo"}))
}

resource datadog_monitor "mongodb_volume_space" {
  name = "PS2Alerts DB volume space"
  type = "query alert"
  query = "max(last_5m):avg:kubernetes.kubelet.volume.stats.available_bytes{persistentvolumeclaim:ps2alerts-db} <= 1073740000"
  message = templatefile("${path.module}/../../dd-monitor-message.tmpl", {environment: var.environment, application: "PS2Alerts Mongo", description: "restarts"})

  thresholds = {
    critical = 1073740000
  }

  notify_no_data = true
  require_full_window = false
  no_data_timeframe = 10

  tags = jsondecode(templatefile("${path.module}/../../dd-tags.tmpl", {environment: var.environment, application: "PS2Alerts Mongo"}))
}
