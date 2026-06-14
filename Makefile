.PHONY: help validate test build up down logs terraform-validate helm-lint

help:
	@echo "Enterprise DevOps Platform"
	@echo "  make validate           Validate applications and infrastructure"
	@echo "  make test               Run application tests"
	@echo "  make build              Build local container images"
	@echo "  make up                 Start the local stack"
	@echo "  make down               Stop the local stack"
	@echo "  make terraform-validate Validate Terraform"
	@echo "  make helm-lint          Lint all Helm charts"

validate: terraform-validate helm-lint test

test:
	cd applications/employee-java-service && mvn -B test
	cd applications/notification-python-service && pytest
	cd applications/payroll-dotnet-service && dotnet build --configuration Release
	cd applications/frontend-angular && npm install && npm run build

build:
	docker compose build

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f

terraform-validate:
	cd infrastructure/terraform && terraform fmt -check -recursive
	cd infrastructure/terraform && terraform init -backend=false
	cd infrastructure/terraform && terraform validate

helm-lint:
	@for chart in gitops/helm-charts/*; do helm lint "$$chart"; done
