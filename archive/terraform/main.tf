terraform {
  backend "s3" {
    bucket = "ps2alerts"
    key    = "terraform/states/ps2alerts-stack"
    region = "eu-west-2"
  }
}

#provider "datadog" {
#  api_key = var.datadog_api_key
#  app_key = var.datadog_app_key
#  api_url = "https://api.datadoghq.eu/"
#}

#module "ps2alerts_datadog" {
#  source                = "./modules/datadog"
#  datadog_api_key       = var.datadog_api_key
#  datadog_app_key       = var.datadog_app_key
#  rabbitmq_datadog_pass = var.rabbitmq_datadog_pass
#}

module "ps2alerts_database" {
  source  = "./modules/database"
  db_user = var.db_user
  db_pass = var.db_pass
}

module "ps2alerts_redis" {
  source     = "./modules/redis"
  redis_pass = var.redis_pass
}

module "ps2alerts_rabbitmq" {
  source                  = "./modules/rabbitmq"
  rabbitmq_admin_pass     = var.rabbitmq_admin_pass
  rabbitmq_ps2alerts_pass = var.rabbitmq_ps2alerts_pass
  rabbitmq_erlang_cookie  = var.rabbitmq_erlang_cookie
}
