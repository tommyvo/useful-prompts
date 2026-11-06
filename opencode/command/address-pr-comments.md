---
description: "Address unresolved GitHub PR review comments"
agent: build
---

# Address PR Comments

Use ONLY the `gh` CLI for every GitHub operation in this skill (fetching, replying, resolving). Do not use any GitHub MCP server or editor GitHub extension tools: they can't see private repos that `gh` can.

**PR Number/URL:** {$ARGUMENTS}

## Step 1: Identify the PR

- If a PR number/URL was provided above (not empty) or mentioned in the conversation, use it.
  Otherwise resolve the current branch's PR:

```bash
gh pr view --json number,title,url
```

## Step 2: Fetch unresolved review threads

The REST API (`gh api repos/{owner}/{repo}/pulls/{number}/comments`) does not expose resolution
state — use the GraphQL API instead:

```bash
gh api graphql -f query='
query {
  repository(owner: "<owner>", name: "<repo>") {
    pullRequest(number: <number>) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          path
          line
          comments(first: 20) {
            nodes { id databaseId author { login } body path diffHunk }
          }
        }
      }
    }
  }
}
'
```

Filter to `isResolved: false` nodes. Each thread's `id` (e.g. `PRRT_...`) is needed to resolve it
later; each comment's `databaseId` is needed to reply to it. If there are many threads, save the
JSON to a temp file and read it rather than parsing inline.

## Step 3: Address each unresolved thread

For every unresolved thread, read the file/line referenced and understand the reviewer's concern
before touching anything — some bots (e.g. optibot) restate stale line numbers after later
commits shift the diff, so verify against the current file contents, not just the diff hunk.

Then decide, per thread:

- **Fix it** — the concern is valid and in-scope. Make the minimal code change that addresses it.
  Update/add specs covering the change. Prefer matching existing patterns in the surrounding code
  over inventing new ones.
- **Comment instead** — the concern is a false positive, out of scope, a deliberate tradeoff, or
  you disagree. Draft a short reply explaining why, but **do not post it yet** — see Step 6.

Don't batch unrelated fixes into one giant diff-reading pass; address threads one at a time so each
fix can be tied back to its thread.

## Step 4: Verify fixes

Before resolving anything, run the affected tests and linter for changed files (see the repo's own
conventions for the exact test/lint commands, or the project's standard test runner otherwise). Fix
any failures before proceeding.

## Step 5: Review the changes

**This step is required whenever Step 3 changed any file.** Skip it only if Step 3 changed no files (every thread got a comment-only reply). Do not start Step 6 until this step is done.

`local-code-review` can only be started by the user as a slash command, so it won't show up in your list of available skills and you can't invoke it as a tool. Instead, read its instructions from `~/.config/opencode/command/local-code-review.md` and follow them yourself, from its mandatory `git diff HEAD` first step through applying the appropriate fixes. If that file doesn't exist, review `git diff HEAD` yourself for correctness, security, clarity, reuse, and consistency, using its priority emojis (🟣 SHOULD FIX, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW).

Output the review report in chat, fix any valid findings, and re-run the affected tests/lint from Step 4 before moving on.

## Step 6: Resolve fixed threads, reply only where you didn't fix

For each thread you **fixed**: resolve it directly, no reply needed.

```bash
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "<PRRT_thread_id>"}) {
    thread { id isResolved }
  }
}
'
```

Multiple threads can be resolved in one GraphQL call by aliasing each mutation (`t1: resolveReviewThread(...) { ... }`, `t2: ...`).

For each thread you decided **not to fix** (false positive, out of scope, deliberate tradeoff, or
disagreement): show the user the drafted reply and get approval before posting anything — don't
post silently on their behalf. Once approved, post it as a reply on the original comment:

```bash
gh api repos/<owner>/<repo>/pulls/<number>/comments/<databaseId>/replies -X POST \
  -f body="<explanation of why this isn't being fixed>"
```

Only resolve that thread if the user also confirms it should be marked resolved — posting the
reply alone doesn't imply resolution.

## Step 7: Summarize

Report back per-thread: what was fixed (with file/line references) and resolved silently, what
tests/lint were run, what the `local-code-review` pass found and fixed (or, if it was
skipped, why), and which threads got a reply instead (with their approval/resolution status).
