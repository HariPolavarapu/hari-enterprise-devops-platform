.PHONY: tf-init tf-fmt tf-validate tf-plan tf-apply

ENV ?= dev
TF_DIR = infrastructure/terraform/environments/$(ENV)

tf-init:
	cd $(TF_DIR) && terraform init

tf-fmt:
	./infrastructure/terraform/scripts/fmt.sh

tf-validate:
	./infrastructure/terraform/scripts/validate.sh

tf-plan:
	./infrastructure/terraform/scripts/plan.sh $(ENV)

tf-apply:
	./infrastructure/terraform/scripts/apply.sh $(ENV)
