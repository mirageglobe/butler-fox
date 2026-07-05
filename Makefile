.DEFAULT_GOAL := help

IMAGE := butler-fox-sandbox

.PHONY: help menu build image test test-swissknife sandbox deploy

help:
	@printf "\n  \033[33mbutler-fox\033[0m\n"
	@printf "\n  usage: make <target>\n\n"
	@awk '/^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", substr($$1, 1, length($$1)-1), substr($$0, index($$0, "##")+3) }' $(MAKEFILE_LIST)
	@printf "\n"

menu: ## show this menu (alias for help)
	@make help

build: ## check dependencies
	command -V docker

image: ## build local sandbox image (run once)
	docker build -t $(IMAGE) .

test: ## lint and test in sandbox container
	docker run --rm -v "$(PWD)":/app -w /app $(IMAGE) bash -c "\
		shellcheck src/fox-sh/fox.sh && \
		bats -r test/* && \
		bash install.sh && \
		~/.fox/bin/fox help"

test-swissknife: ## lint and test the swissknife sub-project (delegates to its own Makefile)
	cd sub-projects/swissknife && $(MAKE) all

sandbox: ## interactive container with fox hot-reloaded from src/
	docker run --rm -it \
		-e TERM \
		-e COLORTERM \
		-v "$(PWD)/src/fox-sh/fox.sh":/usr/local/bin/fox \
		$(IMAGE) \
		bash -c "chmod +x /usr/local/bin/fox && echo '' && echo '[fox] sandbox ready. try: fox help' && echo '' && exec bash"

deploy: ## sync artefacts to dist/
	cp src/fox-sh/fox.sh dist/fox-latest.sh
	cp src/fox-sh/.fox.bash dist/.fox.bash
