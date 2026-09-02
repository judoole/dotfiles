# --- modern replacements, only when actually installed ---------------------
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -l  --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2'
else
  alias ll='ls -lh'
  alias la='ls -lAh'
fi

# --style=plain keeps this a drop-in cat; run `bat` directly for the fancy view.
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'

# fd and rg are intentionally NOT aliased over find/grep — too much muscle
# memory and too many scripts depend on the real flags.

# --- git -------------------------------------------------------------------
alias gs='git status -sb'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'
alias gc='git commit'
alias gca='git commit -a'
alias gac='git add -A && git commit -m'
alias gp='git push origin HEAD'
alias gl='git pull --prune'
alias gd='git diff'
alias gds='git diff --staged'
alias glog="git log --graph --abbrev-commit --date=relative \
--pretty=format:'%Cred%h%Creset %an: %s -%C(yellow)%d%Creset %Cgreen(%cr)%Creset'"

# --- misc ------------------------------------------------------------------
alias m='make'
alias reload='exec zsh'
alias path='print -l $path'
