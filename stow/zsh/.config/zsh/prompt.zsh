if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  # Fallback so a fresh machine still has a usable prompt before `make brew`.
  autoload -U colors && colors
  setopt PROMPT_SUBST
  _fallback_branch() { git symbolic-ref --short HEAD 2>/dev/null }
  PROMPT='%F{cyan}%1~%f %F{green}$(_fallback_branch)%f %# '
fi
