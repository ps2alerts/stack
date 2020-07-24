module "ps2alerts_database" {
  source  = "modules/database"
  db_user = var.db_user
  db_pass = var.db_pass
}
