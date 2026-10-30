output "connection" {
  description = "Mesmo formato do modulo neon."
  sensitive   = true
  value = {
    host           = "${kubernetes_service.postgres.metadata[0].name}.${var.namespace}.svc.cluster.local"
    migration_host = "${kubernetes_service.postgres.metadata[0].name}.${var.namespace}.svc.cluster.local"
    port           = "5432"
    database       = var.db_name
    user           = var.db_user
    password       = random_password.db.result
    ssl            = false
  }
}
