---
name: issue-create
description: Use when the user wants to create or refresh a GitHub issue using a BDD-style description with a user story, Gherkin scenarios, and references at the bottom.
---

# Create Issue

Use this skill when the user asks to create a GitHub issue, draft an issue, refresh an issue description, or open a tracked issue for a problem, feature, or work item.

## Goal

Create or update a GitHub issue whose description is driven by the actual problem statement, affected context, and intended outcome, not by a generic template.

The issue description should use this format:
- a top-level IMPORTANT block containing the user story
- a Gherkin feature section describing the expected or desired behavior
- references at the bottom for issue, PR, doc, or branch context

## GitHub CLI Preference

Prefer GitHub operations through `gh`.

Use `command -v gh` to locate it. Do not hardcode a path.

Use `gh` as much as possible for:
- auth checks
- issue creation
- issue body updates
- issue inspection after creation
- related issue or PR lookup

If `gh` is unavailable or unauthenticated, stop before issue creation and report the blocker clearly.

## Workflow

### 1. Gather context

Determine:
- repo root, if in a repository
- current branch, if relevant
- likely related PR, if one exists
- likely related issue, if one already exists
- the core problem, feature, or work item the user wants tracked

Useful commands:

```bash
git rev-parse --show-toplevel
git rev-parse --abbrev-ref HEAD
git status --short
gh auth status
gh pr list --head <branch> --json number,title,url,body,baseRefName
gh issue list --search <query> --json number,title,url,body,labels
gh issue view <number> --json number,title,body,url,labels
```

If the request appears to duplicate an existing issue, prefer updating or referencing that issue instead of creating a near-duplicate.

### 2. Infer the issue story

Read enough of the user request, branch context, changed files, commit messages, nearby documentation, and related PR or issue context to synthesize:
- who the actor is
- what capability, fix, or investigation is needed
- why it matters
- what outcome or behavior should define completion

Prefer concrete observable behavior over implementation detail.

If there is an existing PR or branch, use it as supporting context, but do not let implementation mechanics dominate the issue narrative.

If the request mixes multiple distinct problems or workstreams, say so explicitly and either:
- focus the issue on the dominant theme, or
- recommend splitting the work into multiple issues

### 3. Draft the issue title

The title should describe the problem to solve or capability to add, not the branch or task mechanics.

Prefer a concise title derived from the main user-facing or operator-facing need.

Examples:
- `Support client-specific configuration resolution in telco engine`
- `Validate airflow parser inputs before DAG import`
- `Prevent token refresh from reusing expired credentials`

### 4. Draft the issue body

Use this structure:

````md
> [!IMPORTANT]
> **As a** <actor>
> **I want** to <feature or outcome>
> **So that** <benefit>

```gherkin
Feature: <problem domain or desired capability>

  Scenario: <primary desired behavior>
    Given <relevant starting state>
    When <action or condition>
    Then <expected outcome>

  Scenario: <important edge case or failure mode>
    Given <relevant starting state>
    When <action or condition>
    Then <expected outcome>
```

## Scope

- <in-scope item>
- <in-scope item>

## Out Of Scope

- <out-of-scope item>
- <out-of-scope item>

## References

- Related PR: #<number>
- Related branch: `<branch>`
- Related docs: <path or link>
````

Rules for the body:
- keep the user story as the main narrative anchor
- keep Gherkin aligned to the desired outcome or expected behavior
- keep scope focused on what the issue is meant to track
- put provenance and implementation context only in `## References`
- do not lead with branch history or low-level implementation detail

When the issue is infrastructure-heavy, describe observable operational behavior such as validation, configuration handling, compatibility, failure modes, or runtime outcomes.

### 5. Create or update the issue

If no matching issue exists:
- create a new issue with `gh issue create`

If a matching issue already exists and the user asked to refresh it:
- update the issue body and title if the existing text is stale or incomplete

Useful commands:

```bash
gh issue create --title <title> --body-file <body-file> --assignee "@me"
gh issue edit <number> --title <title> --body-file <body-file>
gh issue view <number> --json number,url,title,body
```

If labels, assignees, or milestones are clearly implied by nearby issues or the repository workflow, use them. Otherwise, do not invent them.

### 6. Report the outcome

After execution, report:
- issue title
- issue number and URL
- whether the issue was created or updated
- main story captured in the user story
- any uncertainties in the inferred framing

## Safety Rules

- Never create an issue if `gh` is unavailable or unauthenticated.
- Never invent certainty about the actor, feature, or benefit when the request is mixed or ambiguous.
- If the request contains multiple distinct stories, recommend splitting before opening the issue.
- Prefer referencing or updating an existing issue over creating duplicates.
- Keep references at the bottom; do not let provenance dominate the issue narrative.
- Follow repository `CLAUDE.md` or `AGENTS.md` instructions when present.

## Output Contract

In the final response for an issue creation task, include:
- touched files
- commands run
- commands intentionally not run and why
- risk areas before execution
