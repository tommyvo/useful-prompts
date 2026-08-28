---
description: "Investigate a Linear issue across soraban-api and soraban-react-app, design a shared API contract, then create [API] and [UI] coding-agent subtickets. Use when splitting a Linear ticket into implementation subtickets, building Linear tickets from a spec, or the user names a Linear ID (e.g. SOR-12345) for backend/frontend work breakdown."
agent: agent
---

# Linear implementation subtickets

Turn one Linear issue into implementation-ready `[API]` / `[UI]` subtickets that a coding agent can use as the prompt.

Repos (unless the user names others):

- Backend: `~/code/soraban-api`
- Frontend: `~/code/soraban-react-app`

## Required input

The skill takes a Linear issue ID (e.g. `SOR-25066`).

1. If the user passed an ID (in the message, a Linear URL, or `SOR-\d+`), use it.
2. If none was passed, **stop and ask for it**. Do not guess, search Slack, or pick a recent issue.
3. Do not proceed until you have an ID.

## Always start in Plan mode

**Before any investigation, ticket drafting, or Linear writes:**

1. If the session is not already in Plan mode, switch to Plan mode (`SwitchMode` → `plan`). Explain that this skill always plans first.
2. Stay in Plan mode through research and the implementation plan.
3. Do **not** create Linear issues, edit code, or run mutating commands until the user accepts the plan.
4. After the user accepts, execute: create the subtickets only (no product code unless they ask).

## Workflow (Plan mode)

### 1. Load the Linear issue

Fetch the issue (description, comments, attachments, related issues, project, team, labels, priority). Read enough to know the product intent; do not invent requirements that are not in the issue or code.

### 2. Investigate both codebases

Read-only. Map the smallest set of files that must change.

- API: controllers, serializers, models, routes, request specs that already own this surface.
- UI: pages, filters, providers, API clients, types, specs for the same surface.
- Note existing filter/query patterns so the new contract matches them.

Ask the user only when a choice **changes the plan** (filter semantics, which UX paths, scope). Prefer 1–2 questions with sensible defaults.

### 3. Fix the API contract first

Design the request/response (or query params) the frontend will call **as if the API already shipped**. Both tickets must use this exact contract so API and UI can ship in parallel.

State in the plan:

- Endpoint(s) and HTTP method
- Param names, types, omitted vs true/false (or equivalent)
- What “blank” / missing means
- How it composes with existing filters (`count`, `only_ids`, pagination if relevant)

### 4. Draft subtickets in the plan

Put tickets as **subtickets of the same Linear issue**.

Titles:

- Backend: prepend `[API]`
- Frontend: prepend `[UI]`

Each ticket body is a **coding-agent prompt**. Include:

- Context and parent issue
- The shared API contract
- Exact files / symbols to touch
- Implementation guidance (gotchas, backfill, flags, both UX paths if needed)
- Acceptance criteria
- Verification commands

Split so API and UI can proceed independently. Inherit parent team, project, priority, and labels unless the user says otherwise.

Do not implement product code in this skill.

## Execute after plan accept

Create the Linear subtickets with the drafted titles and bodies. Verify parent ID, titles, and URLs. Return the links.

Do not `git commit` or rewrite history.
