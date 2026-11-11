# Dotfiles managed with GNU Stow. Target dir (~) comes from .stowrc.
# Every top-level directory except scripts/ is a stow package.
# scripts/install.sh installs apps and links their configs (one script per app in scripts/apps/).

PACKAGES := $(filter-out scripts,$(patsubst %/,%,$(wildcard */)))
STOW     := stow

.DEFAULT_GOAL := help
.PHONY: help install bootstrap brew link uninstall restow dry-run check

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'
	@echo "  packages: $(PACKAGES)"

install: ## Pick apps to install; link configs of picked and installed apps
	@./scripts/install.sh

bootstrap: ## New machine: install every app and link every config, no prompts
	@./scripts/install.sh --all

brew: ## Install every app without linking configs
	@./scripts/install.sh --all --no-config

check:
	@command -v $(STOW) >/dev/null || { echo "GNU Stow not found. Install it: brew install stow"; exit 1; }

link: check ## Symlink all packages into ~ (installs nothing)
	$(STOW) -v $(PACKAGES)

uninstall: check ## Remove all symlinks from ~
	$(STOW) -v -D $(PACKAGES)

restow: check ## Re-link (prunes stale links after adding/removing files)
	$(STOW) -v -R $(PACKAGES)

dry-run: check ## Show what link would do, without changing anything
	$(STOW) -n -v $(PACKAGES)
