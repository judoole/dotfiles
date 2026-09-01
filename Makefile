# Dotfiles. Every target is idempotent — run any of them as often as you like.
#
#   make            list the targets
#   make bootstrap  full setup on a fresh Mac
#   make doctor     verify the machine matches this repo

SHELL    := /bin/bash
DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
STOW_DIR := $(DOTFILES)/stow
TARGET   := $(HOME)

.DEFAULT_GOAL := help
.PHONY: help bootstrap brew link unlink ai mise doctor check dump

help: ## Show this help
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) \
	| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

bootstrap: brew link mise ai ## Full setup on a fresh Mac
	@echo ""
	@echo "Bootstrap complete. Open a new shell, then:"
	@echo "  make doctor      verify everything landed"
	@echo "  cat MIGRATION.md what still has to be moved by hand"

brew: ## Install everything in the Brewfile
	@command -v brew >/dev/null || { \
	  echo "Homebrew not found. Install it first: https://brew.sh"; exit 1; }
	brew bundle install --file=$(DOTFILES)/Brewfile

link: ## Symlink all stow packages into $HOME (backs up anything in the way)
	@$(DOTFILES)/scripts/link.sh $(STOW_DIR) $(TARGET)

unlink: ## Remove every symlink this repo created
	@for pkg in $$(ls $(STOW_DIR)); do \
	  stow --dir=$(STOW_DIR) --target=$(TARGET) --no-folding --delete $$pkg && echo "unlinked $$pkg"; \
	done

mise: ## Install the runtimes pinned in mise/config.toml
	@command -v mise >/dev/null || { echo "mise not installed; run 'make brew'"; exit 1; }
	mise install
	@mise ls

ai: ## Link agent skills and config into Claude / Codex / Cursor
	@$(DOTFILES)/scripts/link-ai.sh $(DOTFILES)

doctor: ## Verify tools, symlinks and shell health
	@$(DOTFILES)/scripts/doctor.sh $(DOTFILES)

check: ## Are all Brewfile entries actually installed?
	brew bundle check --file=$(DOTFILES)/Brewfile --verbose

dump: ## Show packages installed but missing from the Brewfile (drift)
	@brew bundle dump --file=/tmp/Brewfile.actual --force >/dev/null
	@echo "Installed but not in Brewfile:"
	@comm -23 \
	  <(grep -oE '^(brew|cask) "[^"]+"' /tmp/Brewfile.actual | sort -u) \
	  <(grep -oE '^(brew|cask) "[^"]+"' $(DOTFILES)/Brewfile   | sort -u) \
	| sed 's/^/  /' || true

