# Variables for the infrastructure

variable "external_port" {
  description = "External port for the proxy service"
  type        = number
  default     = 8080
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "secure_password"
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "desafio"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "postgres"
}

# Local values for internal use
locals {
  app_name = "desafio-tecnico"
  environment = "development"
  
  # Network configuration
  external_subnet = "172.100.0.0/16"
  internal_subnet = "172.101.0.0/16"
  
  # Container IPs
  db_ip = "172.101.0.10"
  backend_ip = "172.101.0.20"
  frontend_ip = "172.101.0.30"
  proxy_internal_ip = "172.101.0.100"
  proxy_external_ip = "172.100.0.100"
}