ansible-dependencies:
	@ansible-galaxy install -r requirements.yaml

inventory.yaml: 
	op document get --vault "$(OP_VAULT)"  "inventory.yaml" > inventory.yaml

.env:
	op document get --vault "$(OP_VAULT)"  ".env" > .env

ddns-updater.conf:
	op document get --vault "$(OP_VAULT)"  "ddns-updater.conf" > ddns-updater.conf	

.PHONY: dependencies
dependencies: ansible-dependencies 

.PHONY: site
site: dependencies
	@ansible-playbook -i inventory.yaml site.yaml