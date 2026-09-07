# ~/.zshrc — interactive shells only.

# Homebrew first: everything below may live inside its prefix.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

ZSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Explicit load order, deliberately not a glob. You can read this list and know
# exactly what is loaded and what wins. (The old dotfiles used `$ZSH/**/*.zsh`,
# which made load order an accident of directory naming.)
for _f in path options completion aliases functions tools prompt; do
  [[ -r "$ZSH_CONFIG/$_f.zsh" ]] && source "$ZSH_CONFIG/$_f.zsh"
done
unset _f

# Machine-local and secret config. Never versioned; see MIGRATION.md.
[[ -r "$HOME/.localrc" ]] && source "$HOME/.localrc"
