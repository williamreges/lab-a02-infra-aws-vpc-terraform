variable "regiao" {
  type        = string
  description = "Região da AWS definida"
  default     = "sa-east-1"
}

variable "environment" {
  type        = string
  description = "Ambiente de infra do VPC"
  default     = "dev"
}