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

.PHONY: k8s-python
k8s-python:
	@pip3 install --user kubernetes openshift

.PHONY: cli-tools
cli-tools:
	@echo "Installing Helm, kubectl, and Argo CD CLI..."
	@curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
	@curl -fsSL -o /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
	@chmod +x /usr/local/bin/kubectl
	@ARGOCD_VERSION=$$(curl -fsSL https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep -Po '"tag_name": "\\K.*?(?=")'); \
		curl -fsSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$$ARGOCD_VERSION/argocd-linux-amd64; \
		chmod +x /usr/local/bin/argocd

.PHONY: argocd
argocd: ansible-dependencies k8s-python
	@ansible-playbook -i inventory.yaml playbooks/deploy.yaml --tags argocd

.PHONY: argocd-port-forward
argocd-port-forward:
	@kubectl -n argocd port-forward svc/argocd-server 8080:443

.PHONY: argocd-admin-password
argocd-admin-password:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo