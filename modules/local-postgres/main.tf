# Postgres dentro do cluster, equivalente local do banco gerenciado enquanto a
# conta do Neon nao esta ativa. Mesmo contrato de saida do modulo neon: quem
# consome so le o Secret soat-db.

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

locals {
  name = "soat-db-pg"
  labels = {
    "app.kubernetes.io/name"      = local.name
    "app.kubernetes.io/component" = "database"
    "app.kubernetes.io/part-of"   = "soat"
  }
}

resource "random_password" "db" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "${local.name}-credentials"
    namespace = var.namespace
    labels    = local.labels
  }

  data = {
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = random_password.db.result
    POSTGRES_DB       = var.db_name
  }
}

resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name      = "${local.name}-data"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage
      }
    }
  }

  # O local-path do Kind so liga o volume quando o primeiro pod o consome.
  wait_until_bound = false
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = 1

    # Um PVC ReadWriteOnce nao aguenta dois pods: derruba antes de subir.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = { "app.kubernetes.io/name" = local.name }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        security_context {
          # 70 e o uid do usuario postgres na imagem alpine; fsGroup ajusta o
          # dono do volume para o initdb conseguir escrever.
          run_as_user     = 70
          run_as_group    = 70
          fs_group        = 70
          run_as_non_root = true
        }

        container {
          name  = "postgres"
          image = var.image

          port {
            name           = "postgres"
            container_port = 5432
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.postgres.metadata[0].name
            }
          }

          # O initdb exige diretorio vazio, e o volume pode trazer lost+found.
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          # Mesmo fuso que a aplicacao fixa na sessao: timestamps em UTC.
          env {
            name  = "TZ"
            value = "UTC"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "exec pg_isready -U \"$POSTGRES_USER\" -d \"$POSTGRES_DB\" -h 127.0.0.1"]
            }
            period_seconds    = 5
            failure_threshold = 6
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.data.metadata[0].name
          }
        }
      }
    }
  }

  wait_for_rollout = true
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    selector = { "app.kubernetes.io/name" = local.name }
    port {
      name        = "postgres"
      port        = 5432
      target_port = "postgres"
    }
  }
}
