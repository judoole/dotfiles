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
  ghostty/            .config/ghostty/config
ai/skills/            canonical agent skills, symlinked into every AI tool
ai/codex/             Codex preferences (reference only — see the file)
scripts/              link.sh, link-ai.sh, doctor.sh
```

`stow` mirrors a package directory into the target, so `stow/zsh/.zshrc`
becomes `~/.zshrc`. Real dotted filenames are used rather than stow's
`--dotfiles` renaming, so the mapping stays obvious.

## Design notes

**Why stow and not chezmoi or nix.** The one thing that genuinely differs
between machines is git identity, and that is one prompted file. With no
divergence left to template, the main reason to reach for a templating layer
goes away. What is left is ~150 lines you can read in one sitting, and
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

**Same repo on every machine, work included.** Every machine runs identical
versioned config. The only per-machine difference is git identity, and
`make identity` asks for it:

```
  full name: Ada Lovelace
  email:     ada@example.com
```

That writes `~/.gitconfig.local`, which is never versioned. On a work machine
you enter the work address, and that is the entire work setup — no directory
conventions, no second config file.

**No name or address is committed to this repo.** It is public, so a versioned
`[user]` block would mean anyone who cloned it committed as me until they
noticed.

Two safeguards, because the second catches what the first cannot:

1. `user.useConfigOnly = true` — with no identity configured git **refuses to
   commit** rather than inventing `judoole@<hostname>.local`.
2. `make bootstrap` ends with an identity check, and `make doctor` repeats it,
   so a machine never sits quietly in that state.

If you want a different address for a few repos on a machine, override per
repo rather than reintroducing global rules:

```bash
git config user.email you@example.com
```

**Nothing secret is committed.** `~/.localrc` is sourced last by `.zshrc` and
is never versioned. See MIGRATION.md.

**The terminal is versioned, the editor is not.** Ghostty keeps its config in
a plain file, so it drops into `stow/` like anything else. iTerm2 stores
settings in a plist that does not diff or merge, which is why terminal config
was previously out of scope. Both are in the `Brewfile` — try Ghostty on the
new machine and drop whichever loses.

Note `macos-option-as-alt = true` in the Ghostty config: without it macOS
eats the Option key to type `å`/`∂`/`ƒ` and the alt-word keybindings in
`.config/zsh/options.zsh` never fire. Those bindings cover the escape
sequences iTerm2, Ghostty, WezTerm and kitty each send, so word movement
works whichever you settle on.

**Out of scope on purpose:** macOS `defaults` scripting and VS Code / Cursor
settings. The old repo referenced a `macos/set-defaults.sh`
that did not exist, which is the kind of rot this rewrite is meant to avoid.
