variable "namespace" {
  default = "ps2alerts"
}

variable "redis_identifier" {
  default = "ps2alerts-redis"
}

variable "environment" {
  default = "production"
}

variable "redis_port" {
  default = var.redis_port
}

variable "redis_pass" {
  default = var.redis_pass
}
