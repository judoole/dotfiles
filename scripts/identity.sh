#!/usr/bin/env bash
# Set up this machine's git identity by asking for it.
#
# Nothing in this repo carries a name or address — it is public. Each machine
# gets its own ~/.gitconfig.local, so entering the work address on the work
# machine is the whole of the work setup.
set -uo pipefail

DOTFILES=${1:?usage: identity.sh DOTFILES_DIR [--ensure|--check]}
MODE=${2:---ensure}

local_file="$HOME/.gitconfig.local"

name=$(git -C "$HOME" config user.name  2>/dev/null || true)
email=$(git -C "$HOME" config user.email 2>/dev/null || true)

# A leftover template counts as unconfigured.
[[ "$name" == AUTHORNAME || "$email" == AUTHOREMAIL ]] && { name=; email=; }

if [[ -n "$name" && -n "$email" ]]; then
  printf '  \033[32m ok \033[0m git identity: %s <%s>\n' "$name" "$email"
  exit 0
fi

if [[ "$MODE" == "--check" ]]; then
  printf '\n\033[33m'
  cat <<'MSG'
┌───────────────────────────────────────────────────────────────────────┐
│  ACTION REQUIRED — git has no identity on this machine.               │
│                                                                       │
│    make identity                                                      │
│                                                                       │
│  Until then git REFUSES to commit rather than authoring as            │
│  you@<hostname>.local. That refusal is deliberate.                    │
└───────────────────────────────────────────────────────────────────────┘
MSG
  printf '\033[0m'
  exit 1
fi

# --ensure: ask.
if [[ ! -t 0 ]]; then
  echo "No git identity configured, and no terminal to ask on."
  echo "Run 'make identity' from a terminal, or write $local_file by hand"
  echo "using the template in $DOTFILES/git/gitconfig.local.example"
  exit 1
fi

echo
echo "This machine has no git identity yet. It is written to ~/.gitconfig.local,"
echo "which is never committed — enter the work address on a work machine."
echo

while [[ -z "${in_name:-}" ]]; do
  read -r -p "  full name: " in_name
done
while :; do
  read -r -p "  email:     " in_email
  case "$in_email" in
    *?@?*.?*) break ;;
    *) echo "         that does not look like an email address, try again" ;;
  esac
done

# Built with printf rather than sed over the template: a name can contain
# characters (/, &, backslashes) that would corrupt a sed replacement.
{
  printf "# Written by 'make identity'. Never commit this file.\n"
  printf '[user]\n\tname = %s\n\temail = %s\n' "$in_name" "$in_email"
} > "$local_file"

echo
printf '  \033[32m ok \033[0m wrote %s\n' "${local_file/#$HOME/~}"
printf '  \033[32m ok \033[0m git identity: %s <%s>\n' \
  "$(git -C "$HOME" config user.name)" "$(git -C "$HOME" config user.email)"
