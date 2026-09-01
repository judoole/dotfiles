# Brewfile — everything Homebrew installs on this machine.
#
#   make brew   install everything listed here
#   make dump   regenerate from what is actually installed (drift check)
#
# Keep this honest. The old dotfiles' Brewfile listed 14 packages while the
# machine had 51 installed — which is how a dotfiles repo quietly stops being
# something you can trust to rebuild a laptop.

# ------------------------------------------------------------ shell & CLI
brew "coreutils"        # gls/gdate/etc — GNU behaviour on macOS
brew "stow"             # symlink manager behind `make link`
brew "starship"         # prompt
brew "atuin"            # searchable shell history on ctrl-R
brew "zoxide"           # `z` — frecency directory jumping
brew "fzf"              # fuzzy finder; ctrl-R / ctrl-T bindings
brew "eza"              # ls replacement
brew "bat"              # cat replacement
brew "fd"               # find replacement
brew "ripgrep"          # grep replacement (retires `ack`)
brew "tree"
brew "wget"
brew "jq"
brew "yq"
brew "grc"              # generic output colouriser

# -------------------------------------------------------------------- git
brew "git"
brew "gh"               # GitHub CLI — you use it constantly
brew "git-delta"        # diff pager, wired into .gitconfig
brew "lazygit"          # terminal git UI
brew "gnupg"            # commit signing

# --------------------------------------------------------------- runtimes
# java / node / python / ruby / maven / gradle are all managed by mise.
# See stow/mise/.config/mise/config.toml.
brew "mise"
brew "uv"               # Python packaging and venvs
brew "go"

# ------------------------------------------------------------------- data
brew "go-parquet-tools"

# ------------------------------------------------------------------ other
brew "shellcheck"
brew "adr-tools"
brew "pngquant"
brew "oath-toolkit"     # oathtool — TOTP codes
brew "vercel"

# ------------------------------------------------------------------ casks
cask "iterm2"
cask "visual-studio-code"
cask "cursor"
cask "intellij-idea-ce"
cask "claude"
cask "claude-code"

cask "ngrok"

cask "google-chrome"
cask "firefox"
cask "slack"
cask "spotify"
cask "whatsapp"
cask "zoom"
cask "dropbox"
cask "keybase"

cask "alfred"
cask "divvy"
cask "itsycal"
cask "the-unarchiver"

cask "postman"
cask "beekeeper-studio"
cask "github"

cask "font-jetbrains-mono"

# --------------------------------------------------------------------------
# Deliberately NOT carried over from the old machine:
#
#   atom, xquartz, tunnelbear, virtualbox   dead or unused
#   google-cloud-sdk                        renamed to the gcloud-cli cask
#   temurin@17                              mise installs JDKs now
#   pyenv, rbenv, virtualenv, nvm, sdkman   all replaced by mise
#   node, yarn                              mise installs node; corepack gives yarn
#   ack                                     replaced by ripgrep
#   libgit2, spaceman-diff, mvnvm, roundup  unused in years of shell history
#   minikube, jupyterlab, spark, tcl-tk     installed but absent from recent use;
#                                           add back if you miss them
#   black, flake8                           better as per-project uv deps than
#                                           global installs (consider ruff)
#
# Left out until the new machine's work is known. Add back when needed:
#
#   cloud CLIs      brew install --cask gcloud-cli
#                   brew install awscli
#   containers      brew install colima docker docker-compose
#   orchestration   brew install kubernetes-cli helm
#   iac             brew install terraform
#   databases       brew install postgresql@16   (or libpq for client only)
