resource "helm_release" "ps2alerts_datadog" {
  name       = "ps2alerts-datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = var.namespace

  values = [
    file("${path.module}/datadog-values.yaml")
  ]

  set {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  set {
    name  = "datadog.appKey"
    value = var.datadog_app_key
  }
}