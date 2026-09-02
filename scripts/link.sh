#!/usr/bin/env bash
# Symlink every stow package into the target, moving anything real out of the
# way first. stow refuses to overwrite regular files, so a fresh Mac (which
# ships its own ~/.zshrc the moment you touch it) would otherwise fail here.
set -euo pipefail

STOW_DIR=${1:?usage: link.sh STOW_DIR TARGET}
TARGET=${2:?usage: link.sh STOW_DIR TARGET}
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

command -v stow >/dev/null || {
  echo "stow is not installed. Run 'make brew' first." >&2; exit 1; }

backed_up=0
for pkg_path in "$STOW_DIR"/*/; do
  pkg=$(basename "$pkg_path")

  while IFS= read -r rel; do
    dest="$TARGET/$rel"
    # A real file (not one of our symlinks) is in the way — preserve it.
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$dest" "$BACKUP/$rel"
      echo "  backed up $rel"
      backed_up=1
    fi
  done < <(cd "$pkg_path" && find . -type f | sed 's|^\./||')

  # --restow removes then recreates, so re-running is always a clean no-op.
  # --no-folding links each file individually instead of symlinking whole
  # directories. Without it, stow would fold ~/.config/mise into a single link
  # and anything the tool wrote there would silently land inside this repo.
  stow --dir="$STOW_DIR" --target="$TARGET" --no-folding --restow "$pkg"
  echo "linked $pkg"
done

(( backed_up )) && echo "" && echo "Replaced files were saved in $BACKUP"
exit 0
