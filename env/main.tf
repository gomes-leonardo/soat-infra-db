locals {
  namespace = "soat-${var.environment}"
}

module "local_postgres" {
  source    = "../modules/local-postgres"
  count     = var.db_backend == "local" ? 1 : 0
  namespace = local.namespace
}

module "neon" {
  source      = "../modules/neon"
  count       = var.db_backend == "neon" ? 1 : 0
  environment = var.environment
  region_id   = var.neon_region
  org_id      = var.neon_org_id
}

locals {
  connection = var.db_backend == "neon" ? module.neon[0].connection : module.local_postgres[0].connection
}

# O contrato com a aplicacao e com o substituto local da autenticacao: um
# Secret soat-db no namespace do ambiente. Trocar de banco muda so o conteudo.
resource "kubernetes_secret" "soat_db" {
  metadata {
    name      = "soat-db"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of"    = "soat"
      "app.kubernetes.io/managed-by" = "terraform-soat-infra-db"
    }
  }

  data = {
    DB_HOST           = local.connection.host
    DB_MIGRATION_HOST = local.connection.migration_host
    DB_PORT           = local.connection.port
    DB_NAME           = local.connection.database
    DB_USER           = local.connection.user
    DB_PASS           = local.connection.password
    DB_SSL            = tostring(local.connection.ssl)
  }
}

# A Lambda nao enxerga o cluster: le a URL do banco do SSM. So existe no modo
# neon, porque o Postgres local nao e alcancavel de fora do Mac.
resource "aws_ssm_parameter" "db_url" {
  count       = var.db_backend == "neon" ? 1 : 0
  name        = "/soat/${var.environment}/db/url"
  description = "URL do banco gerenciado (pooler, TLS) para a funcao de autenticacao por CPF"
  type        = "SecureString"
  value = format(
    "postgresql://%s:%s@%s:%s/%s?sslmode=require",
    local.connection.user,
    urlencode(local.connection.password),
    local.connection.host,
    local.connection.port,
    local.connection.database,
  )
}
