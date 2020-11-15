variable "namespace" {
  default = "ps2alerts"
}

variable "identifier" {
  default = "ps2alerts-rabbitmq"
}

variable "environment" {
  default = "production"
}

variable "rabbitmq_admin_pass" {}
variable "rabbitmq_ps2alerts_pass" {}
variable "rabbitmq_datadog_pass" {}
variable "rabbitmq_erlang_cookie" {}
