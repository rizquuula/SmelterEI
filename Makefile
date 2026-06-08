# SmelterEI — Dataset Smelter for Everlasting Intelligence
# Run `make` (or `make help`) to list available commands.

MINERU_DIR := MinerU
DC         := docker compose
DC_GPU     := docker compose -f docker-compose.yaml -f docker-compose.gpu.yaml

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo "SmelterEI — available make targets:"
	@echo
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ---- MinerU (document reader) -----------------------------------------------

.PHONY: mineru-build
mineru-build: ## Build the MinerU CPU image
	cd $(MINERU_DIR) && $(DC) build

.PHONY: mineru-up
mineru-up: ## Start the MinerU API (CPU), building if needed
	cd $(MINERU_DIR) && $(DC) up -d --build

.PHONY: mineru-gpu-up
mineru-gpu-up: ## Start the MinerU API with the GPU override (NVIDIA host)
	cd $(MINERU_DIR) && $(DC_GPU) up -d --build

.PHONY: mineru-down
mineru-down: ## Stop and remove the MinerU containers
	cd $(MINERU_DIR) && $(DC) down

.PHONY: mineru-restart
mineru-restart: ## Restart the MinerU API
	cd $(MINERU_DIR) && $(DC) restart

.PHONY: mineru-logs
mineru-logs: ## Follow the MinerU API logs
	cd $(MINERU_DIR) && $(DC) logs -f

.PHONY: mineru-ps
mineru-ps: ## Show MinerU container status
	cd $(MINERU_DIR) && $(DC) ps

.PHONY: mineru-health
mineru-health: ## Check the API is responding on its port
	@cd $(MINERU_DIR) && set -a && . ./.env && set +a; \
		curl -fsS "http://localhost:$${MINERU_API_PORT:-8000}/docs" >/dev/null \
		&& echo "MinerU API: healthy" \
		|| { echo "MinerU API: not responding"; exit 1; }

.PHONY: mineru-shell
mineru-shell: ## Open a shell inside the running MinerU container
	cd $(MINERU_DIR) && $(DC) exec mineru-api bash

.PHONY: mineru-test
mineru-test: ## Smoke-test the API with a PDF: make mineru-test PDF=path/to/file.pdf
	@test -n "$(PDF)" || { echo "usage: make mineru-test PDF=path/to/file.pdf"; exit 1; }
	cd $(MINERU_DIR) && ./smoke-test.sh "$(abspath $(PDF))"

.PHONY: mineru-config
mineru-config: ## Validate the MinerU compose config
	cd $(MINERU_DIR) && $(DC) config >/dev/null && echo "MinerU compose: valid"

.PHONY: mineru-clean
mineru-clean: ## Stop MinerU and remove its containers + orphans
	cd $(MINERU_DIR) && $(DC) down --remove-orphans

.PHONY: mineru-purge
mineru-purge: ## DESTRUCTIVE: mineru-clean + delete the downloaded model cache
	cd $(MINERU_DIR) && $(DC) down --remove-orphans
	@echo "Deleting $(MINERU_DIR)/models (re-downloads on next parse)..."
	rm -rf $(MINERU_DIR)/models
