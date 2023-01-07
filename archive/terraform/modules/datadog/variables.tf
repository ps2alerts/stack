variable "datadog_api_key" {}
variable "datadog_app_key" {}
variable "namespace" {
  default = "ps2alerts"
}
variable "rabbitmq_datadog_pass" {
  sensitive = true
}
