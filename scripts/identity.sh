#!/usr/bin/env bash
# Create the machine-local git identity files, and report whether git can
# actually resolve an identity yet.
#
# Nothing in this repo carries an identity (it is public), so a fresh machine
# has none until these files are edited. Exits non-zero when unresolved so
# bootstrap can end on a loud, actionable message instead of a quiet one that
# scrolls away.
set -uo pipefail

DOTFILES=${1:?usage: identity.sh DOTFILES_DIR [--ensure|--check]}
MODE=${2:---ensure}

local_file="$HOME/.gitconfig.local"
work_file="$HOME/.gitconfig.work"
work_dir="$HOME/Code/autodesk"

if [[ "$MODE" == "--ensure" ]]; then
  if [[ -f "$local_file" ]]; then
    echo "$HOME/.gitconfig.local already exists"
  else
    cp "$DOTFILES/git/gitconfig.local.example" "$local_file"
    echo "created ~/.gitconfig.local from the example"
  fi
  # Only worth creating on a machine that actually has work repos.
  if [[ -d "$work_dir" && ! -f "$work_file" ]]; then
    cp "$DOTFILES/git/gitconfig.work.example" "$work_file"
    echo "created ~/.gitconfig.work from the example"
  fi
fi

# Resolve the way git will: outside any repo, so the work includeIf is not applied.
name=$(git -C "$HOME" config user.name  2>/dev/null || true)
email=$(git -C "$HOME" config user.email 2>/dev/null || true)

state=ok
[[ -z "$email" || -z "$name" ]] && state=missing
[[ "$email" == *example.com || "$name" == "Your Name" ]] && state=placeholder

work_state=none
if [[ -d "$work_dir" ]]; then
  work_email=$(git config -f "$work_file" user.email 2>/dev/null || true)
  work_state=ok
  [[ -z "$work_email" ]] && work_state=missing
  [[ "$work_email" == *first.last* ]] && work_state=placeholder
fi

if [[ "$state" == ok ]]; then
  printf '  \033[32m ok \033[0m git identity: %s <%s>\n' "$name" "$email"

  case "$work_state" in
    none) exit 0 ;;
    ok)
      printf '  \033[32m ok \033[0m work identity: <%s>\n' "$work_email"
      exit 0 ;;
  esac

  # An unedited ~/.gitconfig.work contributes nothing, so the includeIf falls
  # through and work repos commit under the PERSONAL address. useConfigOnly
  # cannot catch this — a valid identity is set, just the wrong one. So this
  # has to be as loud as a missing identity.
  printf '\n\033[33m'
  cat <<'MSG'
┌───────────────────────────────────────────────────────────────────────┐
│  ACTION REQUIRED — work repos would commit under your PERSONAL email. │
│                                                                       │
│    $EDITOR ~/.gitconfig.work                                          │
│                                                                       │
│  ~/Code/autodesk/ exists, but ~/.gitconfig.work has no usable         │
│  identity, so the includeIf falls through to your personal one.       │
│  Nothing will stop the commit — only this warning.                    │
│                                                                       │
│  Re-check with: make doctor                                           │
└───────────────────────────────────────────────────────────────────────┘
MSG
  printf '\033[0m'
  exit 1
fi

printf '\n\033[33m'
cat <<'MSG'
┌───────────────────────────────────────────────────────────────────────┐
│  ACTION REQUIRED — git has no usable identity on this machine.        │
│                                                                       │
│    $EDITOR ~/.gitconfig.local                                         │
│                                                                       │
│  Uncomment the [user] block and fill in your name and email.          │
│  Until you do, git will REFUSE to commit rather than author as        │
│  you@<hostname>.local. That refusal is deliberate.                    │
│                                                                       │
│  Autodesk machine: also fill in ~/.gitconfig.work, which covers       │
│  every repo under ~/Code/autodesk/.                                   │
│                                                                       │
│  Re-check with: make doctor                                           │
└───────────────────────────────────────────────────────────────────────┘
MSG
printf '\033[0m'
[[ "$state" == placeholder ]] && echo "  (currently reads: ${name:-?} <${email:-unset}> — that is the example placeholder)"
exit 1
