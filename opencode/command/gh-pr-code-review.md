---
description: "Review GitHub Pull Request"
agent: build
---

# Review GitHub Pull Request

Review a GitHub Pull Request using the `gh` CLI tool and provide a comprehensive report with suggestions.

**PR Number:** {$ARGUMENTS}

## CRITICAL: MANDATORY FIRST STEPS

**YOU MUST follow these steps IN ORDER. DO NOT skip any step:**

### Step 1: Get PR Number (MANDATORY)

- **IF** a PR number was provided above (not empty) → Use that number
- **ELSE IF** user mentions a PR number in their message → Use that number
- **ELSE** → Run `gh pr view --json number -q .number` to get it from current branch
- DO NOT proceed without a valid PR number

### Step 2: Gather PR Context (MANDATORY)

Run these `gh` CLI commands **in this exact order** (replace `<number>` with the PR number):

1. **FIRST**: `gh pr view <number>` - Get PR title, description, and metadata
2. **SECOND**: `gh pr diff <number>` - Get ALL code changes (this is your primary source of truth)
3. **THIRD**: `gh pr checks <number>` - Get CI/CD status

**CRITICAL WARNINGS:**
- DO NOT attempt to review the PR without running these commands first
- DO NOT use context or memory - use ONLY the output from these commands
- DO NOT modify the PR - use ONLY read-only `gh` commands
- DO NOT skip any of these three commands

### Step 3: Additional Context (Optional)

You MAY read relevant files in the workspace for additional context if needed.

### Step 4: Choose Review Mode (MANDATORY)

Check the size of the PR: count the changed files and lines, for example with `--shortstat` on the `git diff` command you used, or with `gh pr view <number> --json additions,deletions,changedFiles`. If it touches more than 15 files or more than 800 changed lines, or the user asked for subagents, use **parallel subagents** as described in **Large Reviews: Parallel Subagents** below. Otherwise, or if the user asked not to use subagents, review it yourself in a single pass.

### Step 5: Generate Report (MANDATORY)

Provide the review report directly in the chat (do NOT create files).

Review the PR against the areas listed in **What to Review** below.

**Response Guidelines:**

- Use concrete examples with code snippets
- Quote the original code when suggesting changes
- Provide suggested fixes using unified diff format (see below)
- Include up to 3 questions for the PR author if clarification is needed
- Conclude with a merge recommendation (Safe to merge / Needs changes / Blocking issues)

---

## Large Reviews: Parallel Subagents

Follow this section only if you chose parallel subagents in the "Choose Review Mode" step. If you chose a single pass, ignore this section and review the changes yourself.

**Split the work.** Launch one subagent per topic in **What to Review** below: Correctness, Security, Code clarity, Reusability, and Consistency. If only one unit applies, do not use subagents - review it yourself.

**Brief each subagent.** Subagents do not see this conversation, so each prompt must be self-contained. Include:

- Its unit: the topic name and description, or the full text of its checklist section, copied from this file
- The exact command to get the diff (with branch names or the PR number filled in) and the list of changed files
- The rules: review only the changed lines (and the code they directly affect); read other files only for context; do not modify files, post comments or reviews, or run scanners; never repeat secret values - mask them
- The return format below

**Return format.** Ask each subagent to return only a list of findings, each with: file, lines, priority (using this skill's priority emojis), topic or checklist item, the issue or risk, the quoted code, and a suggested fix as a unified diff. If it finds nothing, it returns exactly `No findings`.

**How to launch them on this platform.** Use the Task tool with the built-in `general` subagent, one task per unit. Start all the tasks at once so they run in parallel. Wait for all of them to return before merging.

**Merge the results.** Once every subagent has returned:

1. Check each finding against the diff yourself, and drop any that are not on changed lines or that you cannot confirm.
2. Merge duplicates: when several subagents flag the same file and lines, keep one finding with the highest priority and note all the topics.
3. Write a single report in the Report Format below, and mention in its opening description that the review was split across N subagents.
4. Only you continue after the report (for example, applying fixes). Subagents never edit files, so their work cannot conflict.

**Fall back instead of failing.** If this platform has no subagent tool, the tool is disabled, or launching fails, review everything yourself in a single pass as usual. If some subagents fail or return nothing usable, review those units yourself and continue. The review must always complete.

## What to Review

1. Correctness (high priority) - Logic errors, bugs, edge cases
2. Security - Vulnerabilities, unsafe practices
3. Code clarity - Readability, maintainability
4. Reusability - Duplication, opportunities to reuse existing code
5. Consistency (low priority) - Style, formatting, naming conventions

Also take into account the PR description, existing review comments, and CI/CD status when judging the change.

---

## Follow-up Checklists

Some languages and frameworks have a dedicated checklist skill for a deeper second pass. Do NOT run these yourself; only suggest one when it applies.

| If the changes include... | Suggest |
| --- | --- |
| `.rb`, `.rake`, `.erb`, `Gemfile`, `db/migrate/` | `gh-pr-rails-review-checklist` (run `/gh-pr-rails-review-checklist`) |
| `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `next.config.*` | `gh-pr-react-review-checklist` (run `/gh-pr-react-review-checklist`) |
| `.tf`, `.tfvars`, `.hcl`, Atmos files (`atmos.yaml`, `stacks/`), `.github/workflows/`, `Dockerfile`, compose files, dependency manifests and lockfiles, `.env*`, credentials config, or code touching authentication, authorization, payments, file uploads, or personal data | `gh-pr-security-review-checklist` (run `/gh-pr-security-review-checklist`) |

If the changes match more than one row (for example, a Rails API and a Next.js frontend), suggest each matching checklist. For the language rows, only suggest a checklist when the change is non-trivial (new or changed logic, components, models, controllers, migrations, or tests), and skip it for docs, config-only changes, renames, formatting, or very small changes. The security row is the exception: suggest it even for small changes (a one-line IAM policy or security group change can matter more than a large refactor), skipping it only for documentation- or formatting-only changes.

---

## Unified Diff Format

When suggesting code changes, use unified diff format:

**Rules:**

- Include the file paths: `--- path/to/file` and `+++ path/to/file` (no timestamps or prefixes)
- Start each hunk with `@@` line indicating line numbers
- Mark removed lines with `-` prefix
- Mark added/new lines with `+` prefix
- Preserve exact indentation and spacing
- Include complete code blocks when editing functions/methods
- To move code: use 2 hunks (1 to delete, 1 to insert)
- To create new files: use `--- /dev/null` to `+++ path/to/new/file`

**Example:**

```diff
--- src/example.js
+++ src/example.js
@@ -10,3 +10,3 @@
 function calculate(x, y) {
-  return x + y;
+  return x * y;
 }
```

---

## Report Format

Structure your review report as follows:

Output the report as normal rendered markdown following the structure below. The code fence below only delimits the template - do not include it in your output or wrap your report in a code fence.

````markdown
# Pull Request Review

**PR:** https://github.com/<repo>/pull/<number>

## Overview

Brief description of what this PR does:

- Adds/Changes/Removes X
- Updates Y
- Refactors Z

## File-Specific Suggestions

### 1. `path/to/file1.js`

**Priority:** 🔴 SHOULD FIX
**Lines:** 15-20

**Issue:** [Describe the problem]

**Current code:**

```js
// Quote the problematic code
```

**Suggested fix:**

```diff
--- path/to/file1.js
+++ path/to/file1.js
@@ -15,2 +15,2 @@
-// old code
+// new code
```

### 2. `path/to/file2.rb`

**Priority:** 🟡 MEDIUM
**Lines:** 8-10

**Issue:** [Describe the problem]

[Continue for each file...]

## Cross-Cutting Concerns

### Inconsistent Error Handling

**Priority:** 🔴 SHOULD FIX

Multiple files need consistent error handling:

**File:** `src/api.js`

```diff
[diff here]
```

**File:** `src/utils.js`

```diff
[diff here]
```

## Questions for PR Author

1. [Question about unclear logic or missing context]
2. [Question about architectural decision]
3. [Question about test coverage]

## Conclusion

**Recommendation:** [Safe to merge ✅ | Needs changes ⚠️ | Blocking issues ❌]

**Summary:** [Brief summary of overall assessment]

## Suggested Follow-ups

(Optional. Omit this section if no follow-up applies. Include only the lines for checklists that match the changes.)

- Ruby/Rails changes detected - consider running `/gh-pr-rails-review-checklist` for a Ruby/Rails smell, antipattern, and testing check.
- JavaScript/TypeScript changes detected - consider running `/gh-pr-react-review-checklist` for a TypeScript, React, Next.js, and testing check.
- Security-sensitive changes detected - consider running `/gh-pr-security-review-checklist` for a security check (application, secrets, supply chain, infrastructure, CI/CD, and SOC 2/GDPR if requested).
````

---

## Priority Levels

Use emoji color-coding for priorities:

- 🟣 CRITICAL - Must fix before merge (security, data loss, breaking changes)
- 🔴 SHOULD FIX - Important issues (bugs, logic errors, significant problems)
- 🟡 MEDIUM - Improvements recommended (code quality, maintainability)
- 🟢 LOW - Nice to have (style, minor optimizations, suggestions)
