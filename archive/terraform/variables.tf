variable "kube_config_path" {
  sensitive = true
}
variable "db_user" {
  sensitive = true
}
variable "db_pass" {
  sensitive = true
}
#variable "datadog_api_key" {}
#variable "datadog_app_key" {}
variable "rabbitmq_admin_pass" {
  sensitive = true
}
variable "rabbitmq_ps2alerts_pass" {
  sensitive = true
}
variable "rabbitmq_erlang_cookie" {
  sensitive = true
}
variable "redis_pass" {
  sensitive = true
}
