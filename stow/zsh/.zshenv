# ~/.zshenv — sourced by EVERY zsh: interactive, scripts, non-login.
# Keep it small and side-effect free. Anything slow or interactive goes in .zshrc.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Where this repo lives. Nothing in the shell config depends on it — it is here
# purely so `cd $DOTFILES` works. Override in ~/.localrc if you clone elsewhere.
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export PROJECTS="${PROJECTS:-$HOME/Code}"

export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-FRX"
