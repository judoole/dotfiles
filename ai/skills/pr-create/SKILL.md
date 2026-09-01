---
name: pr-create
description: Use when the user wants to create or refresh a pull request from the current branch using a BDD-style description with a user story, Gherkin scenarios, and references at the bottom.
---

# Create PR

Use this skill when the user asks to create a pull request, draft a PR, refresh a PR description, or open a GitHub pull request from the current branch.

## Goal

Create or update a pull request whose description is driven by the user's intent, branch state, and issue context, not by a generic template.

The PR description should use this format:
- a top-level IMPORTANT block containing the user story
- a Gherkin feature section describing observable behavior
- references at the bottom for issue or source context

## GitHub CLI Preference

Prefer GitHub operations through `gh`.

Use `command -v gh` to locate it. Do not hardcode a path.

Use `gh` as much as possible for:
- auth checks
- issue-based branch creation
- current PR discovery
- issue lookup
- PR creation
- PR body updates
- PR inspection after creation

If `gh` is unavailable or unauthenticated, stop before PR creation and report the blocker clearly.

## Workflow

### 1. Gather minimal branch context

Determine:
- repo root
- current branch
- base branch
- whether the branch is pushed to remote
- whether a PR already exists for the current branch
- likely related issue from the chat, issue number, branch name, or existing PR metadata

Prefer the fastest reliable path:
- use the current chat message as the primary instruction
- use `gh pr view` or `gh pr list` to detect an existing PR
- use `git status` and `git ls-remote --heads origin <branch>` to confirm local and remote branch state
- only inspect commit history or file changes if the PR title/body is still ambiguous

Useful commands:

```bash
git rev-parse --show-toplevel
git rev-parse --abbrev-ref HEAD
git status --short
git symbolic-ref --quiet --short refs/remotes/origin/HEAD
git log --oneline <base>..HEAD
git diff --name-only <base>..HEAD
git ls-remote --heads origin <branch>
gh auth status
gh issue view <number> --json number,title,body,url,labels
gh pr list --head <branch> --json number,title,url,body,baseRefName
```

If the worktree is dirty, report it before creating the PR so the user is not surprised by a description that does not match committed state.

If an issue number can be inferred, prefer fetching the issue and using it as a source of truth for title framing, actor, feature, benefit, and references.

### 1a. Create the branch from the issue when appropriate

If the user wants a PR and no suitable working branch exists yet, prefer creating the branch from the issue via `gh` instead of inventing a branch name manually.

Use:

```bash
gh issue develop <number> --checkout
```

Use this path when:
- the user refers to an issue directly
- an issue number is known and the user is starting PR work from the issue
- the current branch is the default branch or otherwise not the intended work branch

After creating the branch, continue the PR workflow on that checked out branch.

### 2. Infer the PR story from the changes

Read enough of the chat, issue, existing PR body, and branch metadata to synthesize:
- who the actor is
- what capability or behavior changed
- why the change matters
- which behavior is most important for reviewers to validate

Prefer concrete observable behavior over implementation detail.

Use `git diff`, changed files, and commit messages only when the story is still unclear or the branch appears to contain multiple unrelated concerns.

If an issue exists, use the issue title and body as a strong prior. When the chat or issue still leaves the scope ambiguous, use the diff to confirm the implemented behavior rather than guessing from the plan alone.

If the branch touches multiple unrelated concerns, say so explicitly and either:
- focus on the dominant theme, or
- tell the user the branch should be split before opening the PR

When the branch is clearly single-purpose, do not expand scope by reading unrelated files or browsing extra repository context.

### 3. Draft the PR title

The title should describe the delivered change, not the branch mechanics.

Prefer a concise title derived from the main module or behavior change.

If there is a relevant issue and the implemented work still matches it, prefer the issue title as the starting point and refine only as needed for accuracy.

Examples:
- `telco/engine/configuration: improve config resolution for client overrides`
- `airflow: isolate parser validation for downstream DAG imports`
- `shared auth: add token refresh guard for expired credentials`

### 4. Draft the PR body

Use this structure:

````md
> [!IMPORTANT]
> **As a** <actor>
> **I want** to <feature>
> **So that** <benefit>

```gherkin
Feature: <module capability or change theme>

  Scenario: <primary changed behavior>
    Given <relevant starting state>
    When <action or condition>
    Then <expected outcome>

  Scenario: <important edge case or compatibility behavior>
    Given <relevant starting state>
    When <action or condition>
    Then <expected outcome>
```

Rules for the body:
- keep the user story as the main narrative anchor
- keep Gherkin aligned to the actual changed behavior
- keep scope focused on what this PR delivers
- put issue or provenance context only in `## References`
- do not lead with branch history or "this PR was split from"

If an issue is available:
- reuse the issue's intent when it matches the implemented behavior
- close the issue in `## References` when appropriate, for example `- Closes #<number>`
- carry forward only relevant issue context; do not paste issue body blindly

When the change is infrastructure-heavy, describe observable operational behavior such as validation, configuration handling, compatibility, failure modes, or runtime outcomes.

#### Authoring the body file (avoid escaped backticks)

The body contains triple-backtick fences (```` ```gherkin ````). These MUST reach GitHub as literal backticks, not as `\`` (backslash-escaped) text.

- Write the body to a temp file with the `Write` tool, then pass it via `--body-file`.
- Do NOT build the body through a shell here-doc, `echo`, or `printf`, and do NOT pass it inline via `--body`. Those paths let the shell interpret or escape backticks and dollar signs, which is what produces the broken `\`\`\`gherkin` output.
- After writing the file, verify it before creating the PR, e.g. `head -n 20 <body-file>` — the fence line should read exactly ```` ```gherkin ````, with no leading backslashes.

### 5. Create or update the PR

If no PR exists for the current branch:
- create a PR with `gh pr create`

If a PR already exists:
- update the body and title if the user asked to refresh it or if the existing text is clearly stale

Before creating the PR:
- confirm the branch has commits relative to the base branch
- confirm the branch exists on the remote; if not, push it first
- if the PR story is already clear from chat, issue context, and PR metadata, do not block on additional diff inspection

If the branch is not pushed yet, prefer pushing before PR creation rather than attempting to create the PR against an unpublished branch.

Useful commands:

```bash
gh issue develop <number> --checkout
git push --set-upstream origin <branch>
gh pr create --draft --title <title> --body-file <body-file> --assignee "@me"
gh pr edit <number> --title <title> --body-file <body-file> --add-assignee "@me"
gh pr view --json number,url,title,body
```

Always supply the body through `--body-file` pointing at a file written with the `Write` tool. Never inline the body with `--body` and never assemble it via a shell here-doc, `echo`, or `printf`, because those escape the Gherkin code fence into `\`\`\``.

Always create PRs in draft mode.

Always assign the PR to `@me` on creation, and when updating an existing PR ensure `@me` is added as an assignee.

### 6. Report the outcome

After execution, report:
- branch name
- base branch
- PR title
- PR URL
- whether the PR was created or updated
- main story captured in the user story
- any uncertainties in the inferred framing

## Safety Rules

- Never create a PR if `gh` is unavailable or unauthenticated.
- Never invent certainty about the actor, feature, or benefit when the branch is mixed or ambiguous.
- If the branch contains multiple distinct stories, recommend splitting before opening the PR.
- If the issue and the implemented diff diverge materially, prefer the diff and call out the mismatch.
- Keep references at the bottom; do not let provenance dominate the PR narrative.
- Always use draft mode and assign `@me` when creating PRs with this skill.
- Follow repository `CLAUDE.md` or `AGENTS.md` instructions when present.

## Output Contract

In the final response for a PR creation task, include:
- touched files
- commands run
- commands intentionally not run and why
- risk areas before execution
