# Dotfiles managed with GNU Stow. Target dir (~) comes from .stowrc.
# Every top-level directory is a stow package.

PACKAGES := $(patsubst %/,%,$(wildcard */))
STOW     := stow

.DEFAULT_GOAL := help
.PHONY: help install uninstall restow dry-run check

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'
	@echo "  packages: $(PACKAGES)"

check:
	@command -v $(STOW) >/dev/null || { echo "GNU Stow not found. Install it: brew install stow"; exit 1; }

install: check ## Symlink all packages into ~
	$(STOW) -v $(PACKAGES)

uninstall: check ## Remove all symlinks from ~
	$(STOW) -v -D $(PACKAGES)

restow: check ## Re-link (prunes stale links after adding/removing files)
	$(STOW) -v -R $(PACKAGES)

dry-run: check ## Show what install would do, without changing anything
	$(STOW) -n -v $(PACKAGES)
