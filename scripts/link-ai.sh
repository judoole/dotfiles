#!/usr/bin/env bash
# Link the canonical agent skills into every tool that reads them.
#
# These skills previously lived as diverged copies in ~/.claude/skills,
# ~/.codex/skills and ~/.agents/skills — same names, different contents, with
# the Codex copies hardcoding /opt/homebrew/bin/gh. One source plus symlinks
# means a fix lands everywhere at once.
set -euo pipefail

DOTFILES=${1:?usage: link-ai.sh DOTFILES_DIR}
SKILLS="$DOTFILES/ai/skills"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-ai"

targets=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.agents/skills"
)

count=0
for _ in "$SKILLS"/*/; do count=$((count + 1)); done
backed_up=0

for dir in "${targets[@]}"; do
  mkdir -p "$dir"
  for skill_path in "$SKILLS"/*/; do
    skill=$(basename "$skill_path")
    dest="$dir/$skill"

    if [[ -L "$dest" ]]; then
      rm "$dest"                      # our own link from a previous run
    elif [[ -e "$dest" ]]; then
      mkdir -p "$BACKUP/$(basename "$dir")"
      mv "$dest" "$BACKUP/$(basename "$dir")/$skill"
      echo "  backed up $(basename "$dir")/$skill"
      backed_up=1
    fi

    ln -s "${skill_path%/}" "$dest"
  done
  echo "linked $count skills into ${dir/#$HOME/~}"
done

if (( backed_up )); then
  echo
  echo "Replaced skills were saved in $BACKUP"
fi
