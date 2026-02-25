variable "backend_rg_name" {
  description = "RG del backend Terraform"
  type        = string
}

variable "backend_sa_name" {
  description = "Storage Account del backend"
  type        = string
}

variable "prefix" {
  type    = string
  default = "dr-lab"
}

variable "location" {
  type    = string
  default = "eastus"
}
