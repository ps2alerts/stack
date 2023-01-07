resource "helm_release" "ps2alerts_db" {
  name       = var.identifier
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "12.1.4"

  values = [
    file("${path.module}/mongo-values.yaml")
  ]

  // We have to use these as for some reason the normal way of making extra DBs and databases doesn't work.
  // https://github.com/bitnami/charts/issues/10223
  set {
    name  = "auth.rootUser"
    value = var.db_user
  }
  set {
    name  = "auth.rootPassword"
    value = var.db_pass
  }

  set {
    name  = "metrics.username"
    value = var.db_user
  }
  set {
    name  = "metrics.password"
    value = var.db_pass
  }
}
