# Tool activation hooks. Each is guarded so a half-installed machine still
# gives you a working shell — important on day one of a new Mac.

# mise: single version manager for java, node, python, ruby, maven, gradle.
# Replaces sdkman + nvm + pyenv + rbenv + jenv, which used to load five sets
# of shims on every prompt.
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# zoxide: `z <fuzzy dir>` jumps to frecent directories.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# fzf: ctrl-T files, ctrl-R history, alt-C cd.
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"                        # fzf >= 0.48
  else
    [[ -r "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] \
      && source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  fi
  export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
  (( $+commands[fd] )) && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi

# atuin: searchable shell history on ctrl-R.
# --disable-up-arrow keeps the up/down prefix-search bindings in options.zsh.
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# gh completions
(( $+commands[gh] )) && eval "$(gh completion -s zsh)"

# Cloud CLIs are deliberately not wired in here. If this machine ends up doing
# GCP or AWS work, add the vendor's shell init to ~/.localrc (or a new module
# listed in .zshrc) rather than making it part of the base setup.
