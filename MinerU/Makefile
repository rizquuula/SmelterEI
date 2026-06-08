# MinerU — document reader for SmelterEI
# Run `make` (or `make help`) from this folder to list available commands.

CLIENT := client
SERVER := server
DC     := docker compose

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo "MinerU — available make targets:"
	@echo
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# ---- Client (thin http-client, runs here) -----------------------------------

.PHONY: build
build: ## Build the MinerU client image
	cd $(CLIENT) && $(DC) build

.PHONY: up
up: ## Start the MinerU client, building if needed
	cd $(CLIENT) && $(DC) up -d --build

.PHONY: down
down: ## Stop and remove the MinerU client containers
	cd $(CLIENT) && $(DC) down

.PHONY: restart
restart: ## Restart the MinerU client
	cd $(CLIENT) && $(DC) restart

.PHONY: logs
logs: ## Follow the MinerU client logs
	cd $(CLIENT) && $(DC) logs -f

.PHONY: ps
ps: ## Show MinerU client container status
	cd $(CLIENT) && $(DC) ps

.PHONY: health
health: ## Check the client API is responding on its port
	@cd $(CLIENT) && set -a && . ./.env && set +a; \
		curl -fsS "http://localhost:$${MINERU_API_PORT:-8000}/docs" >/dev/null \
		&& echo "MinerU client: healthy" \
		|| { echo "MinerU client: not responding"; exit 1; }

.PHONY: shell
shell: ## Open a shell inside the running MinerU client container
	cd $(CLIENT) && $(DC) exec mineru-client bash

.PHONY: test
test: ## Smoke-test the client API with a PDF: make test PDF=path/to/file.pdf
	@test -n "$(PDF)" || { echo "usage: make test PDF=path/to/file.pdf"; exit 1; }
	cd $(CLIENT) && ./smoke-test.sh "$(abspath $(PDF))"

.PHONY: config
config: ## Validate the MinerU client compose config
	cd $(CLIENT) && $(DC) config >/dev/null && echo "MinerU client compose: valid"

.PHONY: clean
clean: ## Stop MinerU client and remove its containers + orphans
	cd $(CLIENT) && $(DC) down --remove-orphans

.PHONY: purge
purge: ## DESTRUCTIVE: clean + delete the server model cache
	cd $(CLIENT) && $(DC) down --remove-orphans
	@echo "Deleting $(SERVER)/models (re-downloads on next server start)..."
	rm -rf $(SERVER)/models

# ---- Server (VLM, deploy on the GPU host) -----------------------------------

.PHONY: server-build
server-build: ## Build the MinerU VLM server image (GPU host)
	cd $(SERVER) && $(DC) build

.PHONY: server-up
server-up: ## Start the MinerU VLM server (GPU host), building if needed
	cd $(SERVER) && $(DC) up -d --build

.PHONY: server-config
server-config: ## Validate the MinerU server compose config
	cd $(SERVER) && $(DC) config >/dev/null && echo "MinerU server compose: valid"
