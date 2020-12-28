variable "namespace" {
  default = "ps2alerts"
}

variable "identifier" {
  default = "ps2alerts-rabbitmq"
}

variable "environment" {
  default = "production"
}

variable "rabbitmq_admin_pass" {
  sensitive = true
}
variable "rabbitmq_ps2alerts_pass" {
  sensitive = true
}
variable "rabbitmq_datadog_pass" {
  sensitive = true
}
variable "rabbitmq_erlang_cookie" {
  sensitive = true
}
