# PATH. Homebrew's own entries are already added by `brew shellenv` in .zshrc.

# -U keeps these arrays de-duplicated, so re-sourcing .zshrc never grows PATH.
typeset -U path PATH fpath

path=(
  "$HOME/.local/bin"                     # uv / pipx install here
  ${HOME}/go/bin(N)                      # (N) = skip silently if missing
  $path
)

# Deliberately NOT adding "./bin" to PATH. The old dotfiles did, which means
# cd-ing into any repo could shadow a real command with one from that repo.
