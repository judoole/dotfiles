# Jump into a project: `c <tab>` completes against $PROJECTS.
c() { cd "$PROJECTS/$1"; }
_c() { _files -W "$PROJECTS" -/ }
compdef _c c

# mkdir + cd in one step.
mkcd() { mkdir -p "$1" && cd "$1"; }

# Check out a remote branch by bare name: `gf my-feature`
gf() { git checkout -b "$1" "origin/$1"; }

# Extract most archive formats without remembering the flags.
extract() {
  [[ -f "$1" ]] || { print -u2 "extract: '$1' is not a file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar -jxvf "$1" ;;
    *.tar.gz|*.tgz)   tar -zxvf "$1" ;;
    *.tar.xz)         tar -Jxvf "$1" ;;
    *.tar)            tar -xvf  "$1" ;;
    *.bz2)            bunzip2   "$1" ;;
    *.gz)             gunzip    "$1" ;;
    *.zip|*.ZIP)      unzip     "$1" ;;
    *.dmg)            hdiutil mount "$1" ;;
    *.7z)             7z x      "$1" ;;
    *) print -u2 "extract: don't know how to handle '$1'"; return 1 ;;
  esac
}
