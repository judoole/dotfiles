---
name: start-issue-interview
description: Start a structured Turbineflow issue interview for fuzzy bugs, features, investigations, or operational work; produce a reviewable GitHub issue draft with BDD/Gherkin acceptance criteria, repo references, risks, and validation expectations before creating an issue.
---

# Start Issue Interview

Use this skill when the user wants to turn an unclear Turbineflow work item into a well-scoped GitHub issue through a deliberate interview.

This is not the fast path for obvious issues. It is for work where the actor, problem, scope, acceptance criteria, operational risk, or validation path still needs to be clarified.

## Goal

Guide the user from a fuzzy request to a reviewable issue draft that captures:

- the user story
- expected behavior in BDD/Gherkin form
- scope and out-of-scope boundaries
- relevant repository references
- operational and data-risk concerns
- validation expectations

By default, stop at a draft. Only create or update a GitHub issue when the user explicitly asks you to do so.

## Lightweight Repository Grounding

Use repository context to make the interview sharper, not longer. Before asking a question, inspect only the context needed to avoid asking the user something the repository can answer.

Start with the smallest useful checks:

```bash
git rev-parse --show-toplevel
git rev-parse --abbrev-ref HEAD
git status --short
rg --files -g 'AGENTS.md' -g 'Makefile'
```

Read the relevant `AGENTS.md` files before making process, validation, or safety assumptions. For Turbineflow, the root contract is especially important:

- identify the target module or subproject before validation
- prefer module-local `Makefile` targets
- never run deploy, release, Composer deploy, cloud-costly, data-mutating, or dated script commands without explicit confirmation
- create or update engineering notes only when the workstream policy requires it
- report touched files, commands run, commands intentionally not run, and risk areas in final handoffs

When the request names a module, client, DAG, script, or domain term, inspect nearby docs and code before asking about it. Useful targets can include:

- `docs/CONTRIBUTING.md`
- `docs/developer-guide/ai/ai-guidelines.md`
- `docs/operations/engineering-notes/README.md`
- module-local `Makefile`
- nearby README files, ADRs, runbooks, and workflow files

Do not exhaustively crawl the repository just to begin the interview. Pull in more context as questions require it.

## Interview Rules

Ask one question at a time and wait for the user's answer before continuing.

For each question:

- explain the decision it unlocks in one sentence
- provide your recommended answer when the repository context supports one
- avoid asking if you can inspect code, docs, branch state, or GitHub context instead
- call out conflicting terminology or assumptions directly
- use concrete scenarios to test ambiguous behavior

Keep the interview moving. If there are several open questions, ask the highest-risk or highest-uncertainty one first.

## What To Clarify

Work toward answers for these issue-shaping questions:

- Actor: who needs the change or who is affected?
- Outcome: what capability, fix, or investigation should the issue track?
- Benefit: why does it matter?
- Current behavior: what happens today?
- Desired behavior: what should happen instead?
- Scope: what must be included for this issue to be complete?
- Out of scope: what should not be solved in this issue?
- Risks: does the work touch deploys, IAM, security, data mutation, migrations, backfills, BigQuery, GCS, Composer, production scripts, or customer-sensitive data?
- Validation: which module-local commands or checks should prove the work?
- References: which branch, PR, issue, docs, code paths, logs, or decisions belong at the bottom of the issue?

If the request contains multiple distinct stories, say so and recommend splitting them before drafting.

## Draft Format

When enough context is available, draft the issue in this format:

````md
> [!IMPORTANT]
> **As a** <actor>
> **I want** to <feature, fix, or investigation outcome>
> **So that** <benefit>

```gherkin
Feature: <problem domain or desired capability>

  Scenario: <primary expected behavior>
    Given <relevant starting state>
    When <action or condition>
    Then <expected outcome>

  Scenario: <important edge case, failure mode, or operational guardrail>
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

## Risks And Safety

- <risk area or "No deploy, IAM, data mutation, or cloud-costly risk identified">
- <dry-run, read-only check, or explicit confirmation expectation if needed>

## Validation

- `<module-local command or check>`
- `<module-local command or check>`

## References

- Related issue: #<number>
- Related PR: #<number>
- Related branch: `<branch>`
- Related docs: `<path>`
- Related code: `<path>`
````

Keep provenance and implementation context in `## References`. Do not let branch history or low-level implementation mechanics dominate the user story.

## GitHub Issue Creation

Do not create or update a GitHub issue during the interview unless the user explicitly asks.

If the user asks to create or update the issue:

1. Check authentication and repository identity.
2. Search for likely duplicates.
3. Prefer updating or referencing an existing matching issue over creating a near-duplicate.
4. Create or update the issue using the reviewed draft.
5. Read the issue back and report the URL.

Useful commands:

```bash
gh auth status
gh repo view --json nameWithOwner,url
gh issue list --search "<query>" --json number,title,url,body,labels --limit 10
gh issue view <number> --json number,title,body,url,labels
gh issue create --title "<title>" --body-file <body-file>
gh issue edit <number> --title "<title>" --body-file <body-file>
```

If `gh` is unavailable or unauthenticated, stop before GitHub mutation and explain the blocker.

## Follow-Up Skill Candidates

This skill is intentionally thorough. If the team later wants faster paths, keep them as separate skills with narrower contracts, such as:

- `create-issue-from-brief`: create an issue from an already-clear request with minimal clarification
- `create-issue-from-branch`: infer an issue draft from the current branch, diff, and related PR context
- `refresh-issue-description`: rewrite an existing issue into the Turbineflow issue format

Do not implement those faster paths inside this skill.

## Safety Rules

- Follow the nearest applicable `AGENTS.md`.
- Never run deploy, release, Composer deploy, data mutation, IAM, BigQuery, GCS, or dated script commands as part of the interview.
- Do not include secrets, tokens, customer-sensitive raw payloads, or large raw logs in the issue draft.
- Summarize costly query outputs and operational evidence.
- Recommend an engineering note only when the repo policy requires or clearly benefits from one.
- Prefer concrete observable behavior over implementation detail in Gherkin scenarios.
- Preserve uncertainty when the user has not answered a material question.

## Completion Output

When finishing an interview, report:

- whether this is a draft only or a created/updated GitHub issue
- the issue title
- the main user story
- remaining uncertainties, if any
- touched files, commands run, commands intentionally not run, and risk areas when repository work was performed
