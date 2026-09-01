#!/usr/bin/env bash
# Verify the machine actually matches this repo.
set -uo pipefail

DOTFILES=${1:?usage: doctor.sh DOTFILES_DIR}
fail=0
ok()   { printf '  \033[32m ok \033[0m %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
warn() { printf '  \033[33mwarn\033[0m %s\n' "$1"; }

realpath_of() { python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"; }

echo 'commands on PATH'
for c in brew stow mise starship atuin zoxide fzf eza bat fd rg \
         git gh delta jq yq uv go; do
  if command -v "$c" >/dev/null; then ok "$c"; else bad "$c is missing"; fi
done

echo
echo 'symlinks point into the repo'
for f in .zshrc .zshenv .gitconfig .config/git/ignore \
         .config/zsh/tools.zsh .config/mise/config.toml .config/starship.toml; do
  t="$HOME/$f"
  if [[ -L "$t" ]]; then
    resolved=$(realpath_of "$t")
    if [[ "$resolved" == "$DOTFILES"* ]]; then
      ok "$f"
    else
      bad "$f resolves outside the repo: $resolved"
    fi
  elif [[ -e "$t" ]]; then
    bad "$f exists but is not a symlink"
  else
    bad "$f is missing"
  fi
done

echo
echo 'shell'
if zsh -i -c 'exit' 2>/dev/null; then
  ok 'interactive zsh starts cleanly'
  avg=$(python3 - <<'PY'
import subprocess, time
t = time.time()
for _ in range(5):
    subprocess.run(['zsh', '-i', '-c', 'exit'], capture_output=True)
print(int((time.time() - t) / 5 * 1000))
PY
)
  if [[ "$avg" -lt 800 ]]; then
    ok "startup ${avg}ms avg"
  else
    warn "startup ${avg}ms avg (slow — check tools.zsh)"
  fi
else
  bad "interactive zsh exits non-zero — run 'zsh -i -c exit' to see why"
fi

echo
echo 'packages'
if brew bundle check --file="$DOTFILES/Brewfile" >/dev/null 2>&1; then
  ok 'Brewfile fully satisfied'
else
  warn "Brewfile has unsatisfied entries — run 'make check' for the list"
fi

echo
echo 'runtimes'
if command -v mise >/dev/null; then
  if mise doctor >/dev/null 2>&1; then ok 'mise healthy'; else warn 'mise doctor reports problems'; fi
else
  bad 'mise is missing'
fi

echo
echo 'carried over by hand (see MIGRATION.md)'
if [[ -d "$HOME/.ssh" ]]; then ok 'ssh keys present'
else warn 'ssh directory absent — see MIGRATION.md'; fi
if [[ -d "$HOME/Code/autodesk" ]]; then
  if [[ -r "$HOME/.gitconfig.work" ]]; then
    email=$(git -C "$HOME/Code/autodesk" config user.email 2>/dev/null \
            || git config -f "$HOME/.gitconfig.work" user.email 2>/dev/null)
    ok "work identity configured (${email:-set})"
  else
    warn 'work repos exist but ~/.gitconfig.work is missing — commits will use your personal email'
  fi
fi
if gh auth status >/dev/null 2>&1; then ok 'gh authenticated'
else warn 'gh not authenticated: gh auth login'; fi

echo
if (( fail )); then
  echo 'doctor: FAILURES above'
  exit 1
fi
echo 'doctor: all good'
