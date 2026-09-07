---
name: split-branch
description: Use when the user wants to isolate one logical part of a mixed branch into its own branch and PR, especially when a simple path-only split is too blind and the branch should preserve intent, reviewer context, and follow-up steps.
---

# Split Branch

Use this skill when the user asks to split a mixed branch into a smaller branch or PR for one module, package, project, or logical change.

Do not use `make split-branch` or `bin/split-branch.sh` to perform the split. Read them only as optional background if the current repository contains them.

## Goal

Create a new branch from the appropriate base branch that contains only the changes needed for one logical unit of work, then draft a commit and PR that explain why this split exists and what remains on the original branch.

The key deliverables are:
- a proposed split scope
- a short statement of intent for the split
- a synthetic commit for the isolated work
- a draft PR with reviewer-friendly context

## When To Use

Trigger for requests like:
- "split this branch"
- "create a separate PR for this module"
- "isolate the engine changes"
- "pull out the shared library work first"
- "make a branch for the part that needs to be released first"

## Repository Context

If the current repository has a root `AGENTS.md`, follow it.

If the repository contains any of these, read them for context before executing:
- `docs/developer-guide/local-development/SPLIT_BRANCH.md`
- `bin/split-branch.sh`

Treat them as background only. The actual split should be performed by reasoning from the current diff, not by calling the existing split command.

## GitHub CLI Preference

Prefer GitHub operations through `gh` instead of manual browser steps or ad hoc API calls.

Expected binary:
- `gh`

If `gh` is not on `PATH`, try `gh` explicitly before concluding it is unavailable.

Use `gh` as much as possible for:
- source PR discovery
- issue lookup
- draft PR creation
- PR inspection after creation

If `gh` is unavailable or unauthenticated, continue with the git-only portion when possible and clearly report what GitHub actions were skipped.

## Workflow

### 1. Discover context

Determine:
- repo root
- current branch
- whether the worktree is clean
- base branch, preferably from `origin/HEAD`
- source PR, if one exists
- likely issue number from the branch name, PR title, or branch metadata

Useful commands:

```bash
git rev-parse --show-toplevel
git rev-parse --abbrev-ref HEAD
git status --short
git symbolic-ref --quiet --short refs/remotes/origin/HEAD
gh auth status
gh pr list --head <branch> --json number,title,url,body
git diff --name-only <base>..HEAD
```

If the worktree is dirty, stop before any mutation.

### 2. Infer the split intent

Before selecting files, infer why the split exists.

Read enough context to synthesize:
- what change the user is trying to isolate
- why it should land separately
- what likely depends on it
- what should remain on the source branch

Good sources:
- changed files in the target area
- source PR title/body
- commit messages on the branch
- nearby docs or module metadata

When a source PR exists, prefer `gh` output as the main GitHub context source.

Produce a short "split intent" summary in 2 to 4 sentences before mutation.

### 3. Build a proposed scope

Start with the requested module or path, but do not assume the correct split is path-only.

Select files that are necessary for the isolated intent, including files outside the main path when they are needed for:
- dependency/version changes
- shared library updates
- configuration required by the isolated change
- tests that validate the isolated work
- docs that materially explain the isolated change

Exclude files that belong to the remaining branch story, even if they live near the target path.

Before mutating, present:
- files to include
- files to exclude
- uncertainties or risks

Default to a dry-run style plan unless the user clearly asked for immediate execution.

### 4. Create the split branch

When executing:

1. Create a new branch from the resolved base branch.
2. Bring over only the approved files from the source branch.
3. Review the resulting diff for accidental omissions or unrelated files.
4. Create one synthetic commit.
5. Push the branch.
6. Create a draft PR if `gh` is available and authenticated.
7. Switch back to the original branch after the split flow is complete.

Useful commands:

```bash
git checkout -b <new-branch> <base>
git checkout <source-branch> -- <file1> <file2>
git add <files>
git diff --cached --stat
git commit -F <message-file>
git push --set-upstream origin <new-branch>
gh pr create --draft --title <title> --body-file <body-file> --assignee "@me"
gh pr view --json url,number,title
git checkout <source-branch>
```

Use file-by-file transfer if needed. Prefer correctness over speed.

### 5. Explain the outcome

After execution, report:
- new branch name
- base branch used
- included files or change groups
- excluded files or change groups
- commit title
- PR title and URL if created
- confirmation that the working branch was switched back to the original branch
- follow-up work expected on the original branch

## Naming Guidance

Branch names should reflect the isolated purpose, not just the path. Prefer concise names derived from intent.

Examples:
- `1234-split-engine-config-release`
- `telco-engine-config-release-prep`
- `airflow-shared-parser-extract`

If there is an issue-linked naming convention in the repository, follow it.

## Commit Guidance

Do not use a generic subject like "split changes" unless there is no better option.

The commit subject should describe the isolated work itself.

Suggested pattern:

```text
<scope>: <isolated intent>
```

Suggested body fields:
- `Source branch: <branch>`
- `Source PR: #<number>` if present
- `Related issue: #<number>` if present
- `Split intent: <summary>`
- `Included scope: <short summary>`
- `Deferred scope: <short summary>`

## PR Guidance

The PR should explain the isolated module change in reviewer terms, not center the narrative on the fact that it was split.

Focus the PR on the module or logical unit being delivered:
- what behavior changes in that module
- why that change matters
- how reviewers should evaluate it

Do not lead with "this was split from another branch" or similar framing.
Any source-branch or source-PR provenance belongs at the bottom in a reference section.

Use a structure like:

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

## References

- Source branch: `<source-branch>`
- Source PR: #<number>
- Related issue: #<number>

If uncertainty remains, say so explicitly instead of inventing confidence.

The user story/IMPORTANT section should be the main narrative anchor for the PR.
It should describe:
- who benefits from the module change
- what capability or behavior is being introduced or improved
- why that outcome matters

When drafting the feature section:
- prefer concrete domain behavior over implementation detail
- write scenarios from the perspective of the module's consumer or operator
- keep the scenarios aligned to the isolated scope only
- include 1 to 3 scenarios, not a full specification

If the change is highly technical and not user-facing, the Gherkin should still describe observable behavior such as configuration handling, dependency behavior, validation, or runtime outcomes.

## Safety Rules

- Never mutate git state if the worktree is dirty.
- Never deploy or release anything unless the user explicitly asks.
- Explain mutating actions before execution: branch creation, push, PR creation, issue creation.
- Prefer `gh` for GitHub interactions before falling back to manual instructions.
- Switch back to the original branch before handing off, unless the user explicitly asks to stay on the split branch.
- If the split scope is ambiguous, pause and ask for confirmation instead of guessing.
- If the isolated work depends heavily on many shared files, recommend a broader split or a manual multi-PR strategy.

## Output Contract

In the final response for a split operation, include:
- touched files
- commands run
- commands intentionally not run and why
- risk areas before execution

If no split was executed, still provide the proposed scope and intent summary.
