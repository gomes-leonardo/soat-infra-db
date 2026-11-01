variable "environment" {
  type = string
}

variable "org_id" {
  description = "Organizacao do Neon. Conta com organizacao exige o org_id ao criar projeto."
  type        = string
}

variable "region_id" {
  type = string
}
