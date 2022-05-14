variable "namespace" {
  default = "ps2alerts"
}

variable "identifier" {
  default = "ps2alerts-db"
}

variable "environment" {
  default = "production"
}

variable "db_port" {
  default = 27017
}

variable "db_user" {
  sensitive = true
}

variable "db_pass" {
  sensitive = true
}
