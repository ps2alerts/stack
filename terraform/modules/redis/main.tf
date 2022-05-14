resource "helm_release" "ps2alerts_redis" {
  name       = var.identifier
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "16.9.0"

  values = [
    file("${path.module}/redis-values.yaml")
  ]

  set {
    name  = "auth.password"
    value = var.redis_pass
  }
}
