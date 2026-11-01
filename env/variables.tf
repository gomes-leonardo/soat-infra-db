variable "environment" {
  description = "hml (branch develop) ou prd (branch main)."
  type        = string

  validation {
    condition     = contains(["hml", "prd"], var.environment)
    error_message = "environment deve ser hml ou prd."
  }
}

variable "db_backend" {
  description = "local: Postgres dentro do cluster, equivalente ate a ativacao. neon: banco gerenciado."
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "neon"], var.db_backend)
    error_message = "db_backend deve ser local ou neon."
  }
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  description = "Contexto do cluster criado pelo soat-infra-k8s."
  type        = string
  default     = "kind-soat"
}

variable "region" {
  type    = string
  default = "sa-east-1"
}

variable "neon_region" {
  description = "Regiao do Neon. Sao Paulo, a mesma das Lambdas."
  type        = string
  default     = "aws-sa-east-1"
}

variable "neon_org_id" {
  description = "ID da organizacao do Neon (org-...), em Organization settings. Obrigatorio com db_backend = neon."
  type        = string
  default     = ""

  validation {
    condition     = var.db_backend != "neon" || length(var.neon_org_id) > 0
    error_message = "db_backend = neon exige neon_org_id."
  }
}

variable "neon_api_key" {
  description = "API key do Neon. Obrigatoria com db_backend = neon (no CI: TF_VAR_neon_api_key)."
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.db_backend != "neon" || length(var.neon_api_key) > 0
    error_message = "db_backend = neon exige neon_api_key."
  }
}
