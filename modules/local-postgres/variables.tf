variable "namespace" {
  type = string
}

variable "db_name" {
  type    = string
  default = "soat_repair_shop"
}

variable "db_user" {
  type    = string
  default = "soat_app"
}

variable "storage" {
  type    = string
  default = "1Gi"
}

variable "image" {
  type    = string
  default = "postgres:16-alpine"
}
