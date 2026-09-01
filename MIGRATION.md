# Moving to a new Mac

`make bootstrap` reproduces everything this repo can safely own. This file
covers what it deliberately does not: keys, credentials, and local state.

Keep the old machine intact until `make doctor` passes on the new one.

---

## 1. Before you wipe the old Mac

Copy these across by hand (AirDrop, `scp`, or an encrypted volume). None of
them belong in a git repo.

| What | Why it cannot be automated |
|---|---|
| `~/.ssh/` | Private keys. Copy the directory, keep mode `700`, keys `600`. |
| `~/.gnupg/` | GPG keys, if you sign commits. |
| `~/.localrc` | Machine-local shell config and secrets, sourced last by `.zshrc`. Does not exist yet; create it if you need one. |
| `~/.gitconfig.local` | Optional per-machine git overrides (e.g. a work email). |
| `~/.codex/.env` | Holds a live API key. |
| iTerm2 profile | iTerm2 → Settings → Profiles → Other Actions → Save as JSON. |

**Cloud credentials are intentionally not on this list.** Neither AWS nor GCP
is part of the base setup, because it is not yet clear what this machine will
be used for. The old machine's `~/.aws/credentials` holds 25 profiles of
long-lived static keys, most belonging to former clients — a good thing to
leave behind rather than copy. If the new Mac does end up doing cloud work,
install the vendor CLI then (`brew install --cask gcloud-cli`,
`brew install awscli`) and authenticate fresh, ideally with SSO.

## 2. On the new Mac

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/judoole/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && make bootstrap
```

Open a new shell, then `make doctor`.

## 3. Re-authenticate (no copying needed)

```bash
gh auth login
docker login
```

Sign in to Codex, Claude, Cursor and Dropbox through their apps.

## 4. Regenerates itself — do not copy

- `~/.codex/config.toml` — Codex rewrites it continuously. Merge in
  `ai/codex/config.reference.toml` after first launch.
- `~/.codex/rules/default.rules` — an accumulated per-command allowlist tied to
  old branch names and commit messages. Let it rebuild.
- `~/.codex/logs_2.sqlite` — **296 MB** of local logs on the old machine.
- `~/.zsh_history` — optional, but worth taking. ~1.2 MB of genuinely useful
  history, and atuin will index it on first run.

## 5. Known issue on the old machine

Homebrew 6.0.2 there cannot load current formula definitions
(`undefined method 'stop_timeout'` for `postgresql@*`, `command_wrapper` for
some casks). `make check` reports false failures until `brew update` resolves
it. A fresh Homebrew install on the new Mac is unaffected.
