# Desafio Técnico - Cubos DevOps 🚀

Este projeto implementa uma aplicação web completa utilizando **Docker**, **Terraform** e **JavaScript**, com foco em segurança de redes, proxy reverso e persistência de dados.

## 📋 Visão Geral da Arquitetura

A aplicação é composta por:

- **Frontend**: Interface HTML servida via Nginx
- **Backend**: API REST em Node.js 
- **Banco de Dados**: PostgreSQL 15.8 com dados persistentes
- **Proxy Reverso**: Nginx como gateway de acesso
- **Redes**: Separação entre rede externa (acesso do usuário) e interna (comunicação entre serviços)

### 🏗️ Arquitetura de Redes

```
┌─────────────────────────────────────────────────────────────┐
│                    REDE EXTERNA                              │
│  ┌─────────────────┐                                        │
│  │      PROXY      │ ← Acesso do usuário (porta 8080)      │
│  │   (Gateway)     │                                        │
│  └─────────┬───────┘                                        │
└──────────────────────────────────────────────────────────────┘
           │
           │ Comunicação entre redes
           │
┌──────────▼───────────────────────────────────────────────────┐
│                    REDE INTERNA                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │  FRONTEND   │  │   BACKEND   │  │  DATABASE   │           │
│  │   (Nginx)   │  │  (Node.js)  │  │(PostgreSQL) │           │
│  └─────────────┘  └─────────────┘  └─────────────┘           │
│                                                              │
│  ✅ Serviços isolados e seguros                             |
│  ✅ Comunicação apenas via rede interna                      │
│  ✅ Sem acesso direto do exterior                            │
└──────────────────────────────────────────────────────────────┘
```

## 🛠️ Pré-requisitos

Antes de iniciar, certifique-se de ter instalado:

- **Docker Desktop** (versão 20.10 ou superior)
- **Terraform** (versão 1.0 ou superior) 
- **Git** para clonar o repositório

### 🔧 Instalação das Dependências

#### No Windows:

1. **Docker Desktop**:
   - Baixe em: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
   - Execute o instalador e reinicie o computador
   - Certifique-se de que o Docker Desktop está executando

2. **Terraform**:
   ```powershell
   # Via Chocolatey (recomendado)
   choco install terraform
   
   # Ou baixe manualmente em: https://www.terraform.io/downloads
   ```

3. **Verificação**:
   ```powershell
   docker --version
   terraform --version
   ```

#### No Linux/macOS:

```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verificação
docker --version
terraform --version
```

## 🚀 Como Executar o Projeto

### 1️⃣ Clone o Repositório

```bash
git clone https://github.com/janeiaraujo/desafio-tecnico.git
cd desafio-tecnico
```

### 2️⃣ Inicialize o Terraform

```bash
cd terraform
terraform init
```

### 3️⃣ Revise o Plano de Execução

```bash
terraform plan
```

### 4️⃣ Execute a Infraestrutura

```bash
terraform apply
```

Quando perguntado, digite `yes` para confirmar.

### 5️⃣ Acesse a Aplicação

Após a execução bem-sucedida:

- **Aplicação**: http://localhost:8080
- **API**: http://localhost:8080/api  
- **Health Check**: http://localhost:8080/health

## 🧪 Testando a Aplicação

1. Abra o navegador em `http://localhost:8080`
2. Clique no botão "Verificar Backend e Banco"
3. Aguarde as mensagens de confirmação:
   - ✅ "Database is up" - Banco conectado
   - ✅ "Migration runned" - Usuário admin criado

## 📁 Estrutura do Projeto

```
desafio-tecnico/
├── README.md                 # Documentação (este arquivo)
├── frontend/                 # Interface do usuário
│   ├── index.html           # Página principal
│   ├── nginx.conf           # Configuração do Nginx
│   └── Dockerfile           # Imagem do frontend
├── backend/                 # API REST
│   ├── index.js             # Servidor Node.js
│   ├── package.json         # Dependências
│   └── Dockerfile           # Imagem do backend
├── proxy/                   # Gateway de acesso
│   ├── nginx.conf           # Configuração do proxy
│   └── Dockerfile           # Imagem do proxy
├── database/                # Banco de dados
│   └── Dockerfile           # Imagem customizada PostgreSQL
├── sql/                     # Scripts de inicialização
│   └── script.sql           # Criação de tabelas e dados
└── terraform/               # Infraestrutura como código
    ├── main.tf              # Configuração principal
    ├── variables.tf         # Variáveis
    └── outputs.tf           # Saídas
```

## 🔐 Segurança e Redes

### Redes Implementadas:

- **Rede Externa** (`172.20.0.0/16`): 
  - Apenas o proxy tem acesso
  - Conectada ao host na porta 8080

- **Rede Interna** (`172.21.0.0/16`):
  - Todos os serviços se comunicam
  - Isolada do acesso externo
  - Sem exposição de portas para o host

### IPs dos Serviços:

- **Database**: `172.21.0.10` (somente rede interna)
- **Backend**: `172.21.0.20` (somente rede interna)  
- **Frontend**: `172.21.0.30` (somente rede interna)
- **Proxy**: `172.21.0.100` (rede interna) + `172.20.0.100` (rede externa)

### Variáveis de Ambiente:

O backend utiliza as seguintes variáveis para conexão segura com o banco:

```env
DB_HOST=172.21.0.10
DB_PORT=5432
DB_NAME=desafio
DB_USER=postgres
DB_PASSWORD=secure_password
```

## 💾 Persistência de Dados

- **Volume Docker**: `postgres-data` 
- **Localização**: `/var/lib/postgresql/data`
- **Benefício**: Dados mantidos mesmo com restart dos containers

## 🔄 Restart Automático

Todos os containers são configurados com `restart: unless-stopped`:
- Reinício automático em caso de falha
- Manutenção da disponibilidade
- Recuperação automática após reinicialização do sistema

## 🏥 Health Checks

Implementados health checks para todos os serviços:
- **Database**: `pg_isready`
- **Backend**: Verificação HTTP na porta 3000
- **Proxy**: Endpoint `/health`

## 🛑 Parando a Aplicação

```bash
cd terraform
terraform destroy
```

Digite `yes` para confirmar a remoção de todos os recursos.

## 🐛 Solução de Problemas

### Erro: "Docker daemon not running"
```bash
# Windows: Inicie o Docker Desktop
# Linux: sudo systemctl start docker
```

### Erro: "Port already in use"
```bash
# Verifique processos na porta 8080
netstat -ano | findstr :8080

# Ou altere a porta no terraform/variables.tf
variable "external_port" {
  default = 8081  # Nova porta
}
```

### Erro: "Database connection failed"
```bash
# Verifique se todos os containers estão rodando
docker ps

# Verifique logs do banco
docker logs desafio-database
```

### Limpeza Completa
```bash
# Remove containers, networks e volumes
docker system prune -a --volumes
```

## 🎯 Funcionalidades Extras

### Monitoramento
- Health checks em todos os serviços
- Logs estruturados dos containers
- Status endpoints para verificação

### Observabilidade  
```bash
# Verificar status dos containers
docker ps

# Logs em tempo real
docker logs -f desafio-backend
docker logs -f desafio-database
docker logs -f desafio-proxy

# Inspecionar redes
docker network ls
docker network inspect internal-network
docker network inspect external-network
```

## 📚 Tecnologias Utilizadas

- **Docker & Docker Compose**: Containerização
- **Terraform**: Infraestrutura como Código (IaC)
- **Nginx**: Servidor web e proxy reverso
- **Node.js**: Runtime do backend
- **PostgreSQL 15.8**: Banco de dados relacional
- **HTML/CSS/JavaScript**: Frontend

## 👥 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença ISC - veja o arquivo LICENSE para detalhes.


---

**Desenvolvido por Janei Araujo**