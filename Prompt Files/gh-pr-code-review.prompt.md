---
description: 'Review GitHub Pull Request'
mode: agent
---

# Review GitHub Pull Request

Review a GitHub Pull Request using the `gh` CLI tool and provide a comprehensive report with suggestions.

**Instructions:**

1. If I provide a PR number, use it directly: `gh pr view <number>`
2. If I don't provide a PR number, infer it from the current branch: `gh pr view --json number -q .number`
3. Use read-only `gh` commands to gather context (NEVER modify the PR):
   - `gh pr view <number>` - Get PR details
   - `gh pr diff <number>` - Get code changes
   - `gh pr checks <number>` - Get CI/CD status
4. Read relevant files in the workspace for additional context
5. Provide the review report directly in the chat (do NOT create files)

**Review Focus Areas (in priority order):**

1. 🔴 Correctness - Logic errors, bugs, edge cases
2. 🟠 Security - Vulnerabilities, unsafe practices
3. 🟡 Code Quality - Clarity, maintainability, best practices
4. 🟢 Style - Consistency, formatting, naming conventions

**Response Guidelines:**

- Use concrete examples with code snippets
- Quote the original code when suggesting changes
- Provide suggested fixes using unified diff format (see below)
- Include up to 3 questions for the PR author if clarification is needed
- Conclude with a merge recommendation (Safe to merge / Needs changes / Blocking issues)

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
**Priority:** 🟠 HIGH

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
````

---

## Priority Levels

Use emoji color-coding for priorities:
- 🟣 CRITICAL - Must fix before merge (security, data loss, breaking changes)
- 🔴 SHOULD FIX - Important issues (bugs, logic errors, significant problems)
- 🟡 MEDIUM - Improvements recommended (code quality, maintainability)
- 🟢 LOW - Nice to have (style, minor optimizations, suggestions)
