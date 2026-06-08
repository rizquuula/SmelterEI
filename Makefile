# SmelterEI — Dataset Smelter for Everlasting Intelligence
# Run `make` (or `make help`) to list available commands.

MINERU_CLIENT := MinerU/client
MINERU_SERVER := MinerU/server
DC            := docker compose

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo "SmelterEI — available make targets:"
	@echo
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

# ---- MinerU client (thin http-client, runs here) ----------------------------

.PHONY: mineru-build
mineru-build: ## Build the MinerU client image
	cd $(MINERU_CLIENT) && $(DC) build

.PHONY: mineru-up
mineru-up: ## Start the MinerU client, building if needed
	cd $(MINERU_CLIENT) && $(DC) up -d --build

.PHONY: mineru-down
mineru-down: ## Stop and remove the MinerU client containers
	cd $(MINERU_CLIENT) && $(DC) down

.PHONY: mineru-restart
mineru-restart: ## Restart the MinerU client
	cd $(MINERU_CLIENT) && $(DC) restart

.PHONY: mineru-logs
mineru-logs: ## Follow the MinerU client logs
	cd $(MINERU_CLIENT) && $(DC) logs -f

.PHONY: mineru-ps
mineru-ps: ## Show MinerU client container status
	cd $(MINERU_CLIENT) && $(DC) ps

.PHONY: mineru-health
mineru-health: ## Check the client API is responding on its port
	@cd $(MINERU_CLIENT) && set -a && . ./.env && set +a; \
		curl -fsS "http://localhost:$${MINERU_API_PORT:-8000}/docs" >/dev/null \
		&& echo "MinerU client: healthy" \
		|| { echo "MinerU client: not responding"; exit 1; }

.PHONY: mineru-shell
mineru-shell: ## Open a shell inside the running MinerU client container
	cd $(MINERU_CLIENT) && $(DC) exec mineru-client bash

.PHONY: mineru-test
mineru-test: ## Smoke-test the client API with a PDF: make mineru-test PDF=path/to/file.pdf
	@test -n "$(PDF)" || { echo "usage: make mineru-test PDF=path/to/file.pdf"; exit 1; }
	cd $(MINERU_CLIENT) && ./smoke-test.sh "$(abspath $(PDF))"

.PHONY: mineru-config
mineru-config: ## Validate the MinerU client compose config
	cd $(MINERU_CLIENT) && $(DC) config >/dev/null && echo "MinerU client compose: valid"

.PHONY: mineru-clean
mineru-clean: ## Stop MinerU client and remove its containers + orphans
	cd $(MINERU_CLIENT) && $(DC) down --remove-orphans

.PHONY: mineru-purge
mineru-purge: ## DESTRUCTIVE: mineru-clean + delete the server model cache
	cd $(MINERU_CLIENT) && $(DC) down --remove-orphans
	@echo "Deleting $(MINERU_SERVER)/models (re-downloads on next server start)..."
	rm -rf $(MINERU_SERVER)/models

# ---- MinerU server (VLM, deploy on the GPU host) ----------------------------

.PHONY: mineru-server-build
mineru-server-build: ## Build the MinerU VLM server image (GPU host)
	cd $(MINERU_SERVER) && $(DC) build

.PHONY: mineru-server-up
mineru-server-up: ## Start the MinerU VLM server (GPU host), building if needed
	cd $(MINERU_SERVER) && $(DC) up -d --build

.PHONY: mineru-server-config
mineru-server-config: ## Validate the MinerU server compose config
	cd $(MINERU_SERVER) && $(DC) config >/dev/null && echo "MinerU server compose: valid"
