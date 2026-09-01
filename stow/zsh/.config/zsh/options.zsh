setopt EXTENDED_GLOB

# --- history ---------------------------------------------------------------
# The old config capped this at 10k. There is ~1.2MB of real history worth
# keeping, and atuin indexes it, so there is no reason to be stingy.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY          # record timestamp + duration
setopt INC_APPEND_HISTORY        # write as you go, not only at shell exit
setopt SHARE_HISTORY             # share between concurrent sessions
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE         # leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # !! expands into the buffer, does not run

# --- behaviour -------------------------------------------------------------
setopt AUTO_CD                   # bare directory name = cd into it
setopt AUTO_PUSHD                # every cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt COMPLETE_IN_WORD
setopt INTERACTIVE_COMMENTS      # allow # comments when typing
setopt LOCAL_OPTIONS LOCAL_TRAPS
setopt NO_BEEP NO_LIST_BEEP
setopt NO_BG_NICE                # don't deprioritise background jobs

# Dropped from the old config on purpose:
#   CORRECT           - noisy "did you mean" prompts on every typo
#   COMPLETE_ALIASES  - it blocked branch completion after `gco <tab>`
#   IGNORE_EOF        - ctrl-D should close the shell

# --- keybindings -----------------------------------------------------------
# Up/Down search history for what you have already typed. Kept from the old
# config because you clearly use it; atuin is configured not to steal these.
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[3~'  delete-char
bindkey '^?'     backward-delete-char
