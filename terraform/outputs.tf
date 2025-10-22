# Output important information
output "application_url" {
  description = "URL to access the application"
  value       = "http://localhost:8080"
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = "http://localhost:8080/api"
}

output "proxy_health_check" {
  description = "Proxy health check URL"
  value       = "http://localhost:8080/health"
}

output "external_network_subnet" {
  description = "External network subnet (accessible from host)"
  value       = local.external_subnet
}

output "internal_network_subnet" {
  description = "Internal network subnet (isolated)"
  value       = local.internal_subnet
}

output "containers_info" {
  description = "Information about running containers"
  value = {
    database = {
      name = docker_container.database.name
      internal_ip = "172.21.0.10"
      network = "internal only"
    }
    backend = {
      name = docker_container.backend.name
      internal_ip = "172.21.0.20"
      network = "internal only"
    }
    frontend = {
      name = docker_container.frontend.name
      internal_ip = "172.21.0.30"
      network = "internal only"
    }
    proxy = {
      name = docker_container.proxy.name
      external_ip = "172.20.0.100"
      internal_ip = "172.21.0.100"
      external_port = "8080"
      network = "both external and internal"
    }
  }
}