.PHONY: init plan apply-template apply-nodes destroy-nodes clean

help:
	@echo "  make apply-nodes       - Deploy K3s nodes (automatically depends on template)"
	@echo "  make apply-template    - Create Ubuntu template"
	@echo "  make clean             - Clean local Terraform cache"
	@echo "  make deploy            - Deploy all resources (template + nodes)"
	@echo "  make destroy           - Destroy all resources (template + nodes)"
	@echo "  make init              - Initialise Terraform"
	@echo "  make plan              - Show Terraform plan"
	@echo "  make state-list        - List Terraform state resources"
	@echo "  make state-clean       - Remove resource from Terraform state (usage: make state-clean <resource>)"

# Deploy nodes: will automatically check the template, if the template does not exist it will error, so the order is important
# Here we are not using target, terraform will attempt to deploy all uncreated resources
apply-nodes:
	terraform apply -auto-approve 

# Deploy template: explicitly specify the target
apply-template:
	terraform apply -target=proxmox_virtual_environment_vm.ubuntu_template -auto-approve

# Clean
clean:
	rm -rf .terraform .terraform.lock.hcl

# Deploy all resources
deploy:
	terraform apply -parallelism=1

# Destroy all resources
destroy:
	terraform destroy -auto-approve

init:
	terraform init

plan:
	terraform plan

state-list:
	terraform state list
	
state-clean:
	terraform state rm $(filter-out $@,$(MAKECMDGOALS))