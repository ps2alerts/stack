variable "namespace" {
  default = "ps2alerts"
}

variable "identifier" {
  default = "ps2alerts-redis"
}

variable "environment" {
  default = "production"
}

variable "redis_port" {
  default = 6379
}

variable "redis_pass" {
  sensitive = true
}
