output "connection" {
  description = "Mesmo formato do modulo local-postgres."
  sensitive   = true
  value = {
    # A aplicacao passa pelo pooler; as migrations vao direto ao host, porque
    # o pooler em modo transacao nao e lugar de DDL.
    host           = neon_project.this.database_host_pooler
    migration_host = neon_project.this.database_host
    port           = "5432"
    database       = neon_database.app.name
    user           = neon_role.app.name
    password       = neon_role.app.password
    ssl            = true
  }
}

output "project_id" {
  value = neon_project.this.id
}
