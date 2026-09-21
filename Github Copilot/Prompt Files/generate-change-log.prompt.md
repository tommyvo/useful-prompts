---
description: "Turn one or two commit SHAs from soraban-api and soraban-react-app into a customer-facing Slack change log entry for a nontechnical audience. Use when the user gives a SHA (or a SHA per repo) and asks for a change log, release note, Slack changelog post, or "what should I tell the team about this change"."
agent: agent
---

# Generate change log

Turn commits into a Slack post that marketing, customer service, and sales can read without engineering context.

Default repos:

- API / backend: `~/code/soraban-api`
- Frontend / UI: `~/code/soraban-react-app`

Treat "api", "backend", "server" as `soraban-api`, and "frontend", "UI", "web", "react" as `soraban-react-app`. Other repos are supported — the user just has to say which one, and where it lives on disk.

## Required input

One or two commit SHAs. Valid shapes:

- Two SHAs, one per repo (a change that needed both backend and frontend)
- One SHA in either repo (backend-only or frontend-only change)

**All SHAs passed in one run describe a single change.** Write one entry covering the whole change, never one entry per repo or per commit.

If no SHA was given, stop and ask for one with the `AskQuestion` tool — one question, options `soraban-api`, `soraban-react-app`, `both repos`, `another repo`, so the user can answer the repo inline and supply the SHA as free text. Do not guess from recent history and do not pick a recent commit.

## Workflow

### 1. Resolve each SHA to a repo

If the user named a repo, use it. Map "api"/"backend" to `~/code/soraban-api` and "frontend"/"UI" to `~/code/soraban-react-app`. For any other named repo, use it if it is a git repo under `~/code`; if it is not there, ask the user for its path.

Otherwise, try the two defaults:

```bash
for r in ~/code/soraban-api ~/code/soraban-react-app; do
  git -C "$r" cat-file -e "<sha>^{commit}" 2>/dev/null && echo "$r"
done
```

Stop and ask the user with `AskQuestion` whenever the repo is unclear:

- **Resolves in neither default repo** — ask which repo it belongs to, offering `soraban-api`, `soraban-react-app`, and "another repo (I'll give you the path)". Do not go searching other directories yourself.
- **Resolves in both repos** — likely a short SHA collision. Ask which one is intended.
- **Ambiguous short SHA** (`git cat-file` reports more than one object) — ask for the full SHA.

Never assume a repo to keep moving. Wait for the answer before reading the diff.

### 2. Read the change

```bash
git -C <repo> show --stat --format='%H%n%an%n%ad%n%s%n%n%b' <sha>
git -C <repo> show <sha>
```

Skim the full diff for behavior the customer can observe: new or changed screens, copy, fields, validations, emails/notifications, permissions, defaults, performance. Ignore refactors, test-only churn, and dependency bumps unless they change behavior.

### 3. Find the pull request

Get `owner/repo` from the remote rather than hardcoding it, so this works for any repo:

```bash
git -C <repo> remote get-url origin
gh api repos/<owner>/<repo-name>/commits/<sha>/pulls \
  --jq '.[] | {number, title, body, branch: .head.ref, url: .html_url}'
```

If that returns nothing, the commit may be a squash merge — look for `(#1234)` in the subject and fetch that PR directly, or fall back to `gh pr list --repo <owner>/<repo-name> --state merged --search <sha>`.

The PR description is usually the best source of intent. Read it before the diff conclusions.

### 4. Find the Linear ticket

Search for `SOR-\d+` (case-insensitive) in this order, first match wins:

1. PR branch name
2. PR title
3. PR body (including Linear URLs like `linear.app/.../SOR-25066`)
4. Commit message body

Fetch the issue with the Linear MCP tools and read the description and comments for the customer problem and the "why".

If no ticket is found, continue with the PR and diff alone. Do not invent a ticket reference.

### 5. Establish the "why" before writing

You need two things the diff alone will not give you:

- **The problem the customer had** before this change
- **What they can now do differently**

Sources in priority order: Linear description and comments, PR description, commit messages, diff. If none of them support a customer benefit, say so (see "When a change is not customer-facing") rather than inventing one.

### 6. Write the entry

Audience is nontechnical. Rules:

- No file names, class names, endpoints, table names, flags, ticket IDs, or links
- Translate internal terms into the words a customer would use
- Plain language over precision — "documents now upload faster" beats "reduced S3 round trips"
- Short: roughly 100-150 words total
- Present tense, active voice
- Do not describe backend and frontend as separate work; describe the one change

## Output format

Output **only** the code block. No preamble, no explanation after.

Open with four backticks, close with four backticks:

````markdown
*<One-line headline in plain language>*

*What changed*
<1-2 sentences describing the new behavior as a customer sees it.>

*Why we made this change*
<1-2 sentences on the problem this solves and why it mattered.>

*What it means for customers*
<1-2 sentences, or 2-3 bullets, on the concrete benefit.>
````

Formatting notes:

- Use `*single asterisks*` for bold — that is what Slack renders
- Use `-` for bullets, 4 spaces per nesting level
- No headers (`#`), no tables, no inline code backticks

## Example

Input: one SHA in `soraban-api`, one in `soraban-react-app`, Linear ticket about firms losing track of which client documents were still missing.

Output:

````markdown
*Clients can now see exactly which documents they still owe you*

*What changed*
The client document request page now shows a clear checklist of outstanding items, and marks each one complete the moment it is uploaded. Clients also get a reminder email listing only what is still missing.

*Why we made this change*
Clients were getting a single long request and could not tell what they had already sent. Firms were spending time chasing documents that had, in fact, already come in.

*What it means for customers*
- Clients know at a glance what is left to send
- Fewer back-and-forth emails between firms and their clients
- Faster turnaround on document collection during busy season
````

## When a change is not customer-facing

If the change is an internal refactor, infrastructure work, or a fix with no observable customer effect, do not force a benefit. Say so directly and stop:

> This change is internal only — no customer-visible behavior changed, so there is nothing to post. Here is what it did: <one sentence>.

If the change is customer-facing but you could not determine the "why" from the ticket, PR, or diff, produce the entry with your best reading and flag the gap in one line **outside** the code block.
