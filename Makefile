.DEFAULT_GOAL := help
aws_public_key ?=xxxxxxxxxxxxxxx
tag-environment ?=janitha
AWS_ACCESS_KEY_ID ?= "xxxxxxxxxxxxx"
AWS_SECRET_ACCESS_KEY ?= "xxxxxxxxxxxxxxxx" 
AWS_DEFAULT_REGION ?="us-west-2" 

## validate
validate:
	docker run  -v $(PWD):/app -w /app \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --rm hashicorp/terraform init
	docker run  -v $(PWD):/app -w /app \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --rm hashicorp/terraform "validate"

## Create infra takes variable aws_public_key and tag-environment
apply:
	docker run  -v $(PWD):/app -w /app \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --rm hashicorp/terraform init
	docker run  -v $(PWD):/app -w /app \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --rm hashicorp/terraform "validate"
	docker run  -v $(PWD):/app -w /app \
		--entrypoint "sh" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --rm hashicorp/terraform -c "terraform apply -var=\"aws_public_key=$(aws_public_key)\" -var=\"tag-environment=$(tag-environment)\" -auto-approve"

## Destroy infra, must confirm with yes
destroy:
	docker run  -v $(PWD):/app -w /app \
		--entrypoint "sh" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --rm hashicorp/terraform -c "terraform destroy -auto-approve"

## Copy kubeconfig to local given master_0 and aws_public_key, assumes user file location
getconfig:
	scp -i "$(aws_public_key).pem" -o StrictHostKeyChecking=no ubuntu@$(master_0):~/.kube/config ~/.kube/config

#| jq '.private_ip[0]'
## Show output of apply 
output:
	docker run  -v $(PWD):/app -w /app \
		--entrypoint "sh" \
                --rm hashicorp/terraform -c "terraform output -json" \
		| jq '.masters.value.private_ip[0]'

test:
	THING = $(shell docker run  -v $(PWD):/app -w /app \
                --entrypoint "sh" \
                --rm hashicorp/terraform -c "terraform output -json" \
                | jq '.masters.value.private_ip[0]')
#	@echo ThING is 

test2: 
	HEADER = $(shell for file in `find . -name *.h`;do echo $$file; done)
# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


TARGET_MAX_CHAR_NUM=20
## Show this help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)



.PHONY: apply destroy getconfig help
