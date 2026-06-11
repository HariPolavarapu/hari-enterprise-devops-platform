.PHONY: help setup build build-all deploy deploy-dev deploy-prod deploy-k8s stop health-check logs clean test lint

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER = docker

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
NC = \033[0m # No Color

help:
	@echo "$(GREEN)Hari Enterprise DevOps Platform - Makefile Commands$(NC)"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup              - Setup development environment"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build-employee     - Build Employee Java Service"
	@echo "  make build-notification - Build Notification Python Service"
	@echo "  make build-frontend     - Build Frontend Angular"
	@echo "  make build-payroll      - Build Payroll .NET Service"
	@echo "  make build-all          - Build all services"
	@echo ""
	@echo "Deployment Commands:"
	@echo "  make deploy-dev         - Deploy to local development environment"
	@echo "  make deploy-prod        - Deploy to production (requires DOCKER_REGISTRY)"
	@echo "  make deploy-k8s         - Deploy to Kubernetes"
	@echo ""
	@echo "Service Commands:"
	@echo "  make start              - Start all services"
	@echo "  make stop               - Stop all services"
	@echo "  make restart            - Restart all services"
	@echo "  make logs               - View logs for all services"
	@echo "  make logs-SERVICE       - View logs for specific service"
	@echo ""
	@echo "Database Commands:"
	@echo "  make db-init            - Initialize databases"
	@echo "  make db-backup          - Backup databases"
	@echo ""
	@echo "Health & Testing:"
	@echo "  make health-check       - Check health of all services"
	@echo "  make test               - Run tests for all services"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean              - Clean up containers, images, and logs"
	@echo "  make clean-hard         - Hard clean including volumes and data"
	@echo ""

# Setup
setup:
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@bash scripts/deployment/setup-dev.sh

# Build Commands
build-employee:
	@echo "$(GREEN)Building Employee Java Service...$(NC)"
	@bash scripts/build/build-employee-service.sh

build-notification:
	@echo "$(GREEN)Building Notification Python Service...$(NC)"
	@bash scripts/build/build-notification-service.sh

build-frontend:
	@echo "$(GREEN)Building Frontend Angular...$(NC)"
	@bash scripts/build/build-frontend.sh

build-payroll:
	@echo "$(GREEN)Building Payroll .NET Service...$(NC)"
	@bash scripts/build/build-payroll-service.sh

build-all: build-employee build-notification build-frontend build-payroll
	@echo "$(GREEN)All services built successfully!$(NC)"

# Deployment Commands
deploy-dev: build-all
	@echo "$(GREEN)Deploying to development environment...$(NC)"
	@bash scripts/deployment/deploy-dev.sh

deploy-prod: build-all
	@echo "$(GREEN)Deploying to production...$(NC)"
	@bash scripts/deployment/deploy-prod.sh

deploy-k8s:
	@echo "$(GREEN)Deploying to Kubernetes...$(NC)"
	@bash scripts/deployment/deploy-k8s.sh $(NAMESPACE) $(ENVIRONMENT)

# Service Commands
start:
	@echo "$(GREEN)Starting all services...$(NC)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Services started!$(NC)"

stop:
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@bash scripts/deployment/stop-all.sh

restart: stop start
	@echo "$(GREEN)Services restarted!$(NC)"

ps:
	@$(DOCKER_COMPOSE) ps

# Logs
logs:
	@bash scripts/deployment/view-logs.sh

logs-employee:
	@bash scripts/deployment/view-logs.sh employee-service

logs-notification:
	@bash scripts/deployment/view-logs.sh notification-service

logs-payroll:
	@bash scripts/deployment/view-logs.sh payroll-service

logs-frontend:
	@bash scripts/deployment/view-logs.sh frontend

# Database Commands
db-init:
	@echo "$(GREEN)Initializing databases...$(NC)"
	@bash scripts/database/init-databases.sh

db-backup:
	@echo "$(GREEN)Backing up databases...$(NC)"
	@bash scripts/database/backup-database.sh

# Health Check
health-check:
	@echo "$(GREEN)Checking health of services...$(NC)"
	@bash scripts/deployment/health-check.sh

# Testing
test:
	@echo "$(GREEN)Running tests...$(NC)"
	@echo "Employee Service tests:"
	@cd applications/employee-java-service && mvn test || true
	@echo ""
	@echo "Notification Service tests:"
	@cd applications/notification-python-service && pytest tests/ || true
	@echo ""
	@echo "Frontend tests:"
	@cd applications/frontend-angular && npm test || true

# Linting
lint:
	@echo "$(GREEN)Running linters...$(NC)"
	@cd applications/frontend-angular && npm run lint || true

# Cleanup
clean:
	@echo "$(YELLOW)Cleaning up containers and images...$(NC)"
	@$(DOCKER_COMPOSE) down
	@$(DOCKER) image prune -f --filter "dangling=true"
	@echo "$(GREEN)Cleanup completed!$(NC)"

clean-hard:
	@echo "$(YELLOW)Hard cleaning - removing all containers, images, and volumes...$(NC)"
	@$(DOCKER_COMPOSE) down -v
	@$(DOCKER) system prune -af
	@rm -rf logs/*
	@echo "$(GREEN)Hard cleanup completed!$(NC)"

# Development
dev-setup: setup
	@echo "$(GREEN)Development setup completed!$(NC)"
	@echo "Run 'make deploy-dev' to start the platform"

# Status
status:
	@echo "$(GREEN)Platform Status$(NC)"
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "$(GREEN)Volumes$(NC)"
	@$(DOCKER) volume ls --filter "name=hari"

# Database backup with timestamp
db-backup-now:
	@mkdir -p backups
	@echo "$(GREEN)Creating database backup...$(NC)"
	@bash scripts/database/backup-database.sh ./backups

# Environment info
info:
	@echo "$(GREEN)Environment Information$(NC)"
	@echo "Docker version: $(shell docker --version)"
	@echo "Docker Compose version: $(shell docker-compose --version)"
	@echo "Git version: $(shell git --version)"
	@echo ""
	@echo "$(GREEN)Running Containers$(NC)"
	@$(DOCKER_COMPOSE) ps || true

# Full reset (only in development!)
reset: clean-hard setup
	@echo "$(GREEN)Full reset completed!$(NC)"
	@echo "Run 'make deploy-dev' to redeploy"

.DEFAULT_GOAL := help
