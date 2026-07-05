# swissknife (jsk) Makefile
# Simplify automation for testing, linting, and environment setup.

# --- Configuration ---
.DEFAULT_GOAL := help
.ONESHELL:
SHELL := /bin/bash

# --- Targets ---

##@ General
help: ## Display this help menu
	@awk 'BEGIN { FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"; } \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2; } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5); }' $(MAKEFILE_LIST)

all: lint test ## Run all checks (lint and test)

##@ Development & CI
lint: ## Run ShellCheck on all jsk-*.sh scripts
	@echo "==> Running ShellCheck..."
	@shellcheck jsk-*.sh jsk-help

test: ## Run all Bats and Python tests
	@echo "==> Running Bats tests..."
	@bats *.bats
	@echo "==> Running Python tests..."
	@python3 jsk-system-check-test.py

scan: ## Run vulnerability scan using trivy
	@echo "==> Running trivy scan..."
	@trivy filesystem --scanners vuln,secret,config .

# --- Helper Functions ---
define func_print_header
	echo -e "\n\033[1m=== $(1) ===\033[0m"
endef

define func_print_arrow
	echo -e " \033[32m>\033[0m $(1)"
endef

define func_confirm
	read -p "  [?] $(1) (y/N) " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "Y" ]; then \
		echo "Aborted."; \
		exit 1; \
	fi
endef

##@ Setup
ensure-swissknife: ## Install swissknife tools and setup environment
	@$(call func_print_header,"Ensure Swissknife")
	@$(call func_print_arrow,"Bootstrapping ~/.swissknife/bin and completions")
	@$(call func_confirm,Proceed with setup?)
	@# Create directories
	@mkdir -pv $$HOME/.swissknife/bin $$HOME/.swissknife/completion
	@# Add bin to path if not present (idempotent)
	@grep -qxF 'export PATH="$$HOME/.swissknife/bin:$$PATH"' $$HOME/.bash_profile || \
		(echo "" >> $$HOME/.bash_profile && \
		 echo "# Added by swissknife on $$(date '+%Y-%m-%d %H:%M:%S')" >> $$HOME/.bash_profile && \
		 echo 'export PATH="$$HOME/.swissknife/bin:$$PATH"' >> $$HOME/.bash_profile && \
		 echo "Added to PATH")
	@# Install local scripts
	@echo "Installing jsk (jimmys swissknife) scripts..."
	@cp -v *.sh *.py jsk-help $$HOME/.swissknife/bin/
	@chmod +x $$HOME/.swissknife/bin/*.sh $$HOME/.swissknife/bin/*.py $$HOME/.swissknife/bin/jsk-help
	@# Install semver tool
	@echo "Installing semver..."
	@curl -sLS https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver > $$HOME/.swissknife/bin/semver
	@chmod u+x $$HOME/.swissknife/bin/semver
	@# Install git-completion
	@echo "Installing git-completion..."
	@curl -sLS https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > $$HOME/.swissknife/completion/git-completion.bash
	@# Summary
	@echo ""
	@$(call func_print_arrow,"Setup complete!")
	@echo "Contents of ~/.swissknife/bin:"
	@ls -1 $$HOME/.swissknife/bin
	@echo "Contents of ~/.swissknife/completion:"
	@ls -1 $$HOME/.swissknife/completion
	@echo ""
	@echo "Please restart your shell or run: source ~/.bash_profile"

##@ VM Testing
vm-up: ## Start the vagrant test VM
	vagrant up

vm-ssh: ## SSH into the vagrant test VM
	vagrant ssh

vm-destroy: ## Destroy the vagrant test VM
	vagrant destroy -f

.PHONY: help all lint test scan ensure-swissknife vm-up vm-ssh vm-destroy
