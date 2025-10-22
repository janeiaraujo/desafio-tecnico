# Configure Docker provider
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Configure the Docker Provider
provider "docker" {
  host = "npipe:////.//pipe//docker_engine" # Windows Docker Desktop
}

# Define Docker networks
resource "docker_network" "external_network" {
  name = "external-network"
  driver = "bridge"
  
  ipam_config {
    subnet = local.external_subnet
    gateway = "172.100.0.1"
  }
}

resource "docker_network" "internal_network" {
  name = "internal-network"
  driver = "bridge"
  internal = true
  
  ipam_config {
    subnet = local.internal_subnet
    gateway = "172.101.0.1"
  }
}

# Create volume for PostgreSQL data persistence
resource "docker_volume" "postgres_data" {
  name = "postgres-data"
}

# Build custom images
resource "docker_image" "frontend" {
  name = "desafio-frontend:latest"
  build {
    context = "../frontend"
  }
  keep_locally = true
}

resource "docker_image" "backend" {
  name = "desafio-backend:latest"
  build {
    context = "../backend"
  }
  keep_locally = true
}

resource "docker_image" "proxy" {
  name = "desafio-proxy:latest"
  build {
    context = "../proxy"
  }
  keep_locally = true
}

resource "docker_image" "database" {
  name = "desafio-database:latest"
  build {
    context = "../database"
  }
  keep_locally = true
}

# PostgreSQL Database Container (Internal Network Only)
resource "docker_container" "database" {
  name  = "desafio-database"
  image = docker_image.database.image_id
  
  restart = "unless-stopped"
  
  # Environment variables
  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]
  
  # Internal network only
  networks_advanced {
    name = docker_network.internal_network.name
    ipv4_address = local.db_ip
  }
  
  # Volume for data persistence
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }
  
  # Copy SQL script
  volumes {
    host_path      = abspath("../sql/script.sql")
    container_path = "/docker-entrypoint-initdb.d/init.sql"
    read_only      = true
  }
  
  ports {
    internal = 5432
  }
}

# Backend API Container (Internal Network Only)
resource "docker_container" "backend" {
  name  = "desafio-backend"
  image = docker_image.backend.image_id
  
  restart = "unless-stopped"
  
  # Environment variables for database connection
  env = [
    "PORT=3000",
    "DB_HOST=${local.db_ip}",
    "DB_PORT=5432",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}"
  ]
  
  # Internal network only - not accessible from outside
  networks_advanced {
    name = docker_network.internal_network.name
    ipv4_address = local.backend_ip
  }
  
  ports {
    internal = 3000
  }
  
  # Wait for database to be ready
  depends_on = [docker_container.database]
}

# Frontend Container (Internal Network Only)
resource "docker_container" "frontend" {
  name  = "desafio-frontend"
  image = docker_image.frontend.image_id
  
  restart = "unless-stopped"
  
  # Internal network only - served through proxy
  networks_advanced {
    name = docker_network.internal_network.name
    ipv4_address = local.frontend_ip
  }
  
  ports {
    internal = 80
  }
}

# Proxy/Load Balancer Container (Both Networks)
resource "docker_container" "proxy" {
  name  = "desafio-proxy"
  image = docker_image.proxy.image_id
  
  restart = "unless-stopped"
  
  # External network - accessible from host
  networks_advanced {
    name = docker_network.external_network.name
    ipv4_address = local.proxy_external_ip
  }
  
  # Internal network - can reach backend and frontend
  networks_advanced {
    name = docker_network.internal_network.name
    ipv4_address = local.proxy_internal_ip
  }
  
  ports {
    internal = 80
    external = var.external_port
  }
  
  # Wait for services to be ready
  depends_on = [
    docker_container.frontend,
    docker_container.backend
  ]
}