---
description: "Review GitHub Pull Request"
agent: agent
---

# Review GitHub Pull Request

Review a GitHub Pull Request using the GitHub Pull Request extension and provide a comprehensive report with suggestions.

## CRITICAL: MANDATORY FIRST STEPS

**YOU MUST follow these steps IN ORDER. DO NOT skip any step:**

### Step 1: Get PR Details (MANDATORY)

Use the GitHub Pull Request extension tools to gather PR information:

- **IF** the PR is currently checked out → Use `github-pull-request_activePullRequest` to get PR title, description, changed files, and review comments
- **IF** the PR is open in VS Code → Use `github-pull-request_openPullRequest` to get PR title, description, changed files, and review comments
- **IF** user provides a PR number → Use `github-pull-request_issue_fetch` with the PR number to get PR metadata

DO NOT proceed without PR metadata.

### Step 2: Get Code Diff (MANDATORY)

**DO NOT use `gh pr diff` — it is known to crash VS Code.**

Instead, get the actual code changes using git:

1. Run `gh pr view <number> --json baseRefName,headRefName` to get the base and head branch names
2. Run `git fetch origin` to ensure remote refs are up to date
3. Run `git diff origin/<baseRefName>...origin/<headRefName>` to get all code changes

This is your primary source of truth for the actual code changes.

### Step 3: Get CI/CD Status (MANDATORY)

Use `github-pull-request_pullRequestStatusChecks` with the PR number to get CI/CD status.

**CRITICAL WARNINGS:**
- DO NOT use `gh pr diff` under any circumstances — it crashes VS Code
- DO NOT attempt to review the PR without completing Steps 1-3 first
- DO NOT use context or memory — use ONLY the output from these tools and commands
- DO NOT modify the PR

### Step 4: Additional Context (Optional)

You MAY read relevant files in the workspace for additional context if needed.

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
