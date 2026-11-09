# Dotfiles managed with GNU Stow. Target dir (~) comes from .stowrc.
# Every top-level directory is a stow package.

PACKAGES := $(patsubst %/,%,$(wildcard */))
STOW     := stow
# Resolved at run time so a freshly installed ~/.local/bin/mise is found
MISE     := $$(command -v mise || echo $(HOME)/.local/bin/mise)

.DEFAULT_GOAL := help
.PHONY: help brew bootstrap install uninstall restow dry-run check

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'
	@echo "  packages: $(PACKAGES)"

brew: ## Install tools and apps from the Brewfile
	@command -v brew >/dev/null || { echo "Homebrew is required first: https://brew.sh"; exit 1; }
	brew bundle --file=Brewfile

bootstrap: ## New machine: install stow + mise, link dotfiles, install tools
	@command -v brew >/dev/null || { echo "Homebrew is required first: https://brew.sh"; exit 1; }
	@command -v $(STOW) >/dev/null || brew install stow
	@command -v mise >/dev/null || [ -x $(HOME)/.local/bin/mise ] || curl -fsSL https://mise.run | sh
	@$(MAKE) --no-print-directory install
	$(MISE) install --yes
	$(MISE) exec -- corepack enable
	$(MISE) reshim
	@echo "Done. Open a new terminal (or run: exec zsh -l)."

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
