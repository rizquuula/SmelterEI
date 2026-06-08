# SmelterEI — Dataset Smelter for Everlasting Intelligence
# Run `make` (or `make help`) to list available commands.

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo "SmelterEI — available make targets:"
	@echo
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "MinerU (document reader) has its own Makefile: cd MinerU && make"
