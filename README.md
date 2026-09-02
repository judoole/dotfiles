# dotfiles

macOS development environment as a repo. Plain files, GNU stow for symlinks,
a Makefile as the only interface. No framework to learn.

## Fresh Mac, from zero

```bash
# 1. Xcode command line tools (gives you git)
xcode-select --install

# 2. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. This repo
git clone https://github.com/judoole/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && make bootstrap

# 4. Open a new shell, then
make doctor
```

Then work through [MIGRATION.md](MIGRATION.md) for the things a repo should
not carry: SSH keys, GPG keys, and re-authentication.

## Targets

| Command | Does |
|---|---|
| `make` | List targets |
| `make bootstrap` | brew → link → mise → ai. The whole setup. |
| `make brew` | Install everything in the `Brewfile` |
| `make link` | Symlink `stow/*` into `$HOME` (backs up anything in the way) |
| `make identity` | Create the git identity files and verify git can use them |
| `make unlink` | Remove every symlink this repo created |
| `make mise` | Install the runtimes pinned in `mise/config.toml` |
| `make ai` | Link agent skills into Claude / Codex / Cursor |
| `make doctor` | Verify tools, symlinks, shell health, auth state |
| `make check` | Are all `Brewfile` entries installed? |
| `make dump` | Show packages installed but missing from the `Brewfile` |

Everything is idempotent. Run any target as often as you like.

## Layout

```
Brewfile              packages and apps
stow/                 each subdir is a stow package mirrored into $HOME
  zsh/                .zshenv, .zshrc, .config/zsh/*.zsh
  git/                .gitconfig, .config/git/ignore
  mise/               .config/mise/config.toml
  starship/           .config/starship.toml
ai/skills/            canonical agent skills, symlinked into every AI tool
ai/codex/             Codex preferences (reference only — see the file)
scripts/              link.sh, link-ai.sh, doctor.sh
```

`stow` mirrors a package directory into the target, so `stow/zsh/.zshrc`
becomes `~/.zshrc`. Real dotted filenames are used rather than stow's
`--dotfiles` renaming, so the mapping stays obvious.

## Design notes

**Why stow and not chezmoi or nix.** The one thing that genuinely differs
between machines is git identity, and git solves that itself with
`includeIf` (see below). That removes the main reason to reach for a
templating layer. What is left is ~150 lines you can read in one sitting, and
`make unlink` reverses all of it.

**One version manager.** `mise` replaces sdkman + nvm + pyenv + rbenv + jenv,
which previously all loaded shims on every prompt. Per-project `mise.toml`,
`.tool-versions`, and `.java-version` files still work. `uv` stays for Python
packaging.

**Explicit shell load order.** `.zshrc` sources a fixed list —
`path, options, completion, aliases, functions, tools, prompt`. The previous
setup globbed `$ZSH/**/*.zsh`, which made load order an accident of directory
naming.

**The shell config does not know where this repo lives.** Nothing sources a
file from `$DOTFILES`, so the repo can be cloned anywhere.

**Same repo on every machine, including work.** Personal and Autodesk
machines run identical versioned config. Git identity is chosen by *where the
repo lives*, not which machine you are on:

| Repo location | Commits as | From |
|---|---|---|
| `~/Code/autodesk/**` | Autodesk address | `~/.gitconfig.work` |
| anywhere else | personal address | `~/.gitconfig.local` |

**No identity is committed to this repo.** It is public, so a versioned
`[user]` block would mean anyone who cloned it committed as me until they
noticed. Both identity files are created per machine from the examples in
`git/`.

Three safeguards, because each catches a case the others cannot:

1. `user.useConfigOnly = true` — with no identity configured git **refuses to
   commit** rather than inventing `judoole@<hostname>.local`.
2. Both example files ship with their values **commented out**, so an unedited
   copy still trips the refusal. A placeholder address git would happily
   accept is worse than an error.
3. `make bootstrap` **ends** with an identity check, and `make doctor` repeats
   it. This is the only thing that catches an unedited `~/.gitconfig.work`:
   the `includeIf` then contributes nothing, work repos fall through to your
   personal identity, and git has no reason to complain — a valid identity is
   set, just the wrong one.

Selecting on repo location rather than hostname means a personal side project
cloned onto the Autodesk Mac still commits as you.

**Nothing secret is committed.** `~/.localrc` is sourced last by `.zshrc` and
is never versioned. See MIGRATION.md.

**Out of scope on purpose:** macOS `defaults` scripting, VS Code / Cursor
settings, and terminal profiles. The old repo referenced a `macos/set-defaults.sh`
that did not exist, which is the kind of rot this rewrite is meant to avoid.
