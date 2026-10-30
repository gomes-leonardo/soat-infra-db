output "db_backend" {
  value = var.db_backend
}

output "db_host" {
  description = "Host que a aplicacao usa (pooler, no Neon)."
  value       = local.connection.host
  sensitive   = true
}
