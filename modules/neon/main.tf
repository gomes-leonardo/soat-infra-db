# Banco gerenciado: um projeto Neon por ambiente, cada um com a propria cota
# do plano gratuito (100 CU-hora/mes, 0,5 GB). Papel e banco dedicados, em vez
# do papel padrao do projeto.

terraform {
  required_providers {
    neon = {
      source = "kislerdm/neon"
    }
  }
}

resource "neon_project" "this" {
  name       = "soat-${var.environment}"
  org_id     = var.org_id
  region_id  = var.region_id
  pg_version = 16

  # O plano gratuito permite no maximo 6 horas de historico para restore; o
  # default do provider (1 dia) seria recusado.
  history_retention_seconds = 21600
}

resource "neon_role" "app" {
  project_id = neon_project.this.id
  branch_id  = neon_project.this.default_branch_id
  name       = "soat_app"
}

resource "neon_database" "app" {
  project_id = neon_project.this.id
  branch_id  = neon_project.this.default_branch_id
  name       = "soat_repair_shop"
  owner_name = neon_role.app.name
}
