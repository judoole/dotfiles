---
name: help-me-finish-github-issue
description: "Work through a GitHub issue end to end: inspect and refine the issue, start from the latest origin default branch, create an issue branch, set project status to In progress, implement the change, validate it, and report the result. Use when the user asks to start, work on, implement, or finish a GitHub issue."
---

# Help Me Finish a GitHub Issue

Turn a GitHub issue into a validated implementation. If running in an isolated git worktree (via EnterWorktree), prepare the worktree before changing code.

## Workflow

### 1. Resolve and inspect the issue

- Use the issue number supplied by the user. If none is available, ask for it.
- Verify GitHub CLI authentication with `gh auth status`.
- Read the issue with `gh issue view <number> --json number,title,body,labels,url,projectItems`.
- Summarize the requested outcome, acceptance criteria, labels, project status, and unresolved ambiguity.
- If ambiguity would materially change the implementation, clarify it before creating a branch or changing project status.
- Preserve the issue body unless the user approves an edit.

### 2. Inspect repository guidance

- Confirm the current directory is inside the repository associated with the issue.
- Read the applicable `CLAUDE.md` or `AGENTS.md` files and repository workflow documentation before changing code.
- Inspect the relevant implementation and tests. Do not invent repository conventions.

### 3. Prepare the worktree

Complete this step before implementation so the issue branch starts from the latest remote default branch.

1. Check `git status --short --branch`. If tracked or untracked changes are present, stop and ask how to handle them; do not discard or carry them onto the issue branch implicitly.
2. Fetch current remote state with `git fetch origin --prune`.
3. Resolve the base ref in this order:
   - the symbolic target of `refs/remotes/origin/HEAD`
   - `origin/main`
   - `origin/master`
4. Fail clearly if none of those remote refs exists.
5. Create and switch to a new branch from the resolved remote ref:

   ```bash
   git switch -c issue-<number>-<short-slug> <base-ref>
   ```

- Verify the new branch has the resolved base commit as its starting point.
- Treat the fetched remote ref as the source of truth.
- Stop before implementation if fetching the remote fails.
- Do not check out local `main` or `master`; another worktree may already have it checked out.
- Do not use `git pull` to prepare the worktree.
- Do not reset, delete, or rewrite an existing branch. If the intended issue branch already exists or the current branch contains issue work, inspect it and ask before choosing a recovery strategy.

### 4. Mark the issue in progress

After preparing the fresh issue branch and before planning or implementation work proceeds, set the issue's GitHub Projects status to `In progress`.

- Use the issue's existing project item and the exact status option exposed by that project.
- Prefer `gh project item-list`, `gh project field-list`, and `gh project item-edit`; use `gh api graphql` only when the project commands cannot expose the required IDs.
- Match the status name case-insensitively, but do not guess an alternative status.
- If the issue belongs to multiple projects, update the project that owns the active workflow. If ownership is ambiguous, ask before changing project state.
- If the issue is not in a project, the status field does not exist, permissions are insufficient, or no `In progress` option exists, report the limitation and ask whether to continue without the status update.
- Do not confuse project status with the issue's open/closed state or with labels.

### 5. Refine and plan

- If the issue is unclear or lacks acceptance criteria, propose a concise clarification before implementation.
- Edit the issue only after the user approves the exact change.
- Produce a short ordered implementation plan based on repository evidence.
- Call out dependencies, risks, unknowns, documentation impact, and validation.
- Offer to append an approved plan to the issue as a Markdown checklist. Preserve the existing body.

### 6. Implement the issue

- Make the smallest focused change that satisfies the issue and repository guidance.
- Keep code, tests, and user-facing documentation aligned.
- Avoid unrelated refactors and preserve existing behavior outside the issue scope.
- Update an issue checklist only when the corresponding work is actually complete.

### 7. Validate and report

- Run the most relevant tests plus lint and type checking when practical.
- Review the final diff for scope, regressions, accidental files, and unresolved checklist items.
- Report:
  - issue number, title, and URL
  - base ref and fetched base commit
  - issue branch name
  - project status result
  - implementation summary
  - validation performed and any failures
  - issue body or checklist updates
  - remaining risks or follow-up work

## GitHub CLI Rules

- Prefer `gh` for GitHub reads and writes.
- Locate it with `command -v gh`; do not assume a platform-specific path.
- Stop and report the blocker if `gh` is missing or unauthenticated.
- Request only the additional scopes required for project operations; commonly `read:project` for discovery and `project` for updates.
- Never guess issue content, project IDs, field IDs, option IDs, or repository ownership.
- Recommend splitting the issue when it contains multiple unrelated deliverables.
