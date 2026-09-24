---
description: "Rails Review Checklist for GitHub Pull Request"
agent: agent
---

# GitHub PR Rails Review Checklist

Review a GitHub Pull Request using the GitHub Pull Request extension and check its Ruby and Rails changes against the checklists below. This complements `gh-pr-code-review` (general correctness, security, clarity); it does not repeat that review.

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

### Step 5: Check Scope (MANDATORY)

If the PR diff contains no Ruby/Rails files (`.rb`, `.rake`, `.erb`, `Gemfile`, `db/migrate/`, `config/` for a Rails app), output a single line saying there are no Ruby/Rails changes to check, and stop.

### Step 6: Choose Review Mode (MANDATORY)

Check the size of the PR: count the changed files and lines, for example with `--shortstat` on the `git diff` command you used, or with `gh pr view <number> --json additions,deletions,changedFiles`. If it touches more than 15 files or more than 800 changed lines, or the user asked for subagents, use **parallel subagents** as described in **Large Reviews: Parallel Subagents** below. Otherwise, or if the user asked not to use subagents, review it yourself in a single pass.

### Step 7: Generate Report (MANDATORY)

Provide the review report directly in the chat (do NOT create files).

Review the PR's changes against BOTH checklists below. Only report items that actually appear in the diff.

**Response Guidelines:**

- This skill is report-only. Do NOT modify any files, and do NOT post comments or reviews to the PR
- Only review the lines the PR changed (and the code they directly affect). Do not audit pre-existing code that the PR did not touch
- Use judgment: a checklist item is a prompt to look, not a rule to enforce. Skip items that are not a real problem in context, and prefer a few well-explained findings over a long list of nitpicks
- Use concrete examples with code snippets
- Quote the original code when suggesting changes
- Provide suggested fixes using unified diff format (see below)
- Include up to 3 questions for the PR author if clarification is needed
- **Only include files in the report that have specific suggestions or issues.** Do not create sections for files that look good with no changes needed

---

## Large Reviews: Parallel Subagents

Follow this section only if you chose parallel subagents in the "Choose Review Mode" step. If you chose a single pass, ignore this section and review the changes yourself.

**Split the work.** Launch one subagent per checklist unit: the Ruby Checklist, the Rails Checklist's "Design and data" items, and the Rails Checklist's "Testing" items. Skip any unit that does not apply to the diff. If only one unit applies, do not use subagents - review it yourself.

**Brief each subagent.** Subagents do not see this conversation, so each prompt must be self-contained. Include:

- Its unit: the topic name and description, or the full text of its checklist section, copied from this file
- The exact command to get the diff (with branch names or the PR number filled in) and the list of changed files
- The rules: review only the changed lines (and the code they directly affect); read other files only for context; do not modify files, post comments or reviews, or run scanners; never repeat secret values - mask them
- The return format below

**Return format.** Ask each subagent to return only a list of findings, each with: file, lines, priority (using this skill's priority emojis), topic or checklist item, the issue or risk, the quoted code, and a suggested fix as a unified diff. If it finds nothing, it returns exactly `No findings`.

**How to launch them on this platform.** Use the `runSubagent` tool (part of the `agent` tool set), one call per unit, run in parallel. Wait for all of them to return before merging. If the tool is not available (for example, it is not enabled in the tools picker), use the fallback below. Give subagents the `git diff` command on the fetched refs; they must never use `gh pr diff`.

**Merge the results.** Once every subagent has returned:

1. Check each finding against the diff yourself, and drop any that are not on changed lines or that you cannot confirm.
2. Merge duplicates: when several subagents flag the same file and lines, keep one finding with the highest priority and note all the topics.
3. Write a single report in the Report Format below, and mention in its opening description that the review was split across N subagents.
4. Only you continue after the report (for example, applying fixes). Subagents never edit files, so their work cannot conflict.

**Fall back instead of failing.** If this platform has no subagent tool, the tool is disabled, or launching fails, review everything yourself in a single pass as usual. If some subagents fail or return nothing usable, review those units yourself and continue. The review must always complete.

## Ruby Checklist (applies to any Ruby code, not just Rails)

Code smells to look for in the changed code:

1. **Long method / large class** - A method or class doing several jobs. Fix: extract methods or classes, each with one reason to change.
2. **Long parameter list** - Four or more parameters, or booleans that switch behavior. Fix: introduce a parameter object, keyword arguments, or split the method.
3. **Feature envy** - A method that mostly calls another object's data. Fix: move the behavior to the object that owns the data.
4. **Law of Demeter violations** - Train wrecks such as `order.customer.address.city`. Fix: delegate (`delegate :city, to: :customer`) or add a method that hides the chain.
5. **Primitive obsession** - Strings, hashes, or arrays standing in for a concept (money, status, address). Fix: introduce a small value object.
6. **Duplicated code** - The same logic copied or near-copied. Fix: extract a method, module, or class; but only when the duplication is real, not coincidental.
7. **Conditional complexity** - Long `if`/`case` chains switching on type or status. Fix: polymorphism, a lookup table, or a small strategy object.
8. **Nested conditionals / missing guard clauses** - Deep nesting hiding the main path. Fix: early returns.
9. **Shotgun surgery / divergent change** - One change forcing edits across many files, or one file changing for unrelated reasons. Fix: consolidate or split responsibilities.
10. **Mutable or global state** - Class variables, `$globals`, memoized state shared across requests or threads, mutating arguments. Fix: pass values in, return new values.
11. **Monkey patching / `method_missing` overuse** - Reopening core or third-party classes, or dynamic dispatch without `respond_to_missing?`. Fix: refinements, wrapper objects, or explicit methods.
12. **Error handling** - `rescue Exception`, bare `rescue`, swallowed errors, or using exceptions for normal flow. Fix: rescue specific errors and handle or re-raise them.
13. **Dead or commented-out code** - Unused methods, branches, or leftover debugging (`binding.pry`, `puts`). Fix: delete it.
14. **Unclear naming and comments** - Names that hide intent, or comments that explain what confusing code does. Fix: rename or extract a well-named method.

## Rails Checklist

### Design and data

1. **Fat controller** - Business logic, queries, or multi-step orchestration in a controller action. Fix: move it to a model, service object, or form object; keep controllers to params, calling, and responding.
2. **Fat model / god object** - A model accumulating unrelated responsibilities. Fix: extract concerns sparingly, or better, plain objects (service, query, form, policy).
3. **Logic in views, helpers, or callbacks** - Business rules in ERB, helpers, or `after_save`-style callbacks that trigger side effects (email, jobs, external calls). Fix: make the side effect explicit at the call site.
4. **N+1 queries** - Associations accessed in a loop or view without `includes`/`preload`. Fix: eager load, and check the new queries in the diff.
5. **Unsafe query building** - String interpolation in `where`, `order`, or `find_by_sql`. Fix: use placeholders or hash conditions; whitelist `order` inputs.
6. **`default_scope`** - Hidden filtering or ordering that surprises later queries. Fix: use a named scope.
7. **Skipping validations or callbacks** - `update_all`, `update_column`, `save(validate: false)`, `delete` without a clear reason. Fix: use the normal path, or document why not.
8. **Strong parameters and mass assignment** - `permit!`, overly broad `permit`, or attributes like `role`/`admin` that a user could set. Fix: permit explicit keys only.
9. **Missing authorization or scoping** - Records loaded with `Model.find(params[:id])` where they should be scoped to the current user or account. Fix: scope through the owner association or use the authorization layer.
10. **Migrations** - Missing indexes on foreign keys or frequently queried columns, missing `null: false`/foreign key constraints or defaults, a non-reversible `change`, a data backfill mixed into a schema migration, a long table lock on a big table. Fix: add the index/constraint, define `up`/`down`, and separate data changes.
11. **Callbacks and validations vs. database constraints** - A uniqueness validation with no unique index. Fix: add the index; the validation alone races.
12. **Background jobs and external calls** - Network calls inside a request or transaction, jobs that are not idempotent, or enqueueing inside a transaction before commit. Fix: enqueue after commit and make jobs safe to retry.

### Testing

1. **Missing tests** - New behavior, branches, or endpoints with no corresponding spec/test in the diff. Fix: add tests for the behavior, including the failure paths.
2. **Testing implementation, not behavior** - Assertions on private methods or exact call sequences. Fix: assert on observable outcomes.
3. **Over-mocking** - Stubbing the object under test or stubbing so much that the test cannot fail. Fix: use real objects; stub only at system boundaries (HTTP, time, third parties).
4. **Unnecessary database or slow work** - `create` where `build`/`build_stubbed` is enough; system tests for logic a unit test covers. Fix: use the cheapest test that gives confidence.
5. **Brittle setup** - Deep `let`/`before` chains, mystery guests, or shared state that make tests hard to read. Fix: keep setup local and explicit to each example.
6. **Factory bloat** - Factories that create many associations by default. Fix: keep factories minimal and use traits.
7. **Coverage at the right level** - A new endpoint with no request spec, or a user flow with no system spec. Fix: add coverage at the boundary that changed.
8. **Flaky tests** - Dependence on the current time, ordering, random data, or network. Fix: freeze time, sort explicitly, and seed or stub randomness.

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
# Pull Request Rails Review Checklist

**PR:** https://github.com/<repo>/pull/<number>

## Overview

Brief description of the Ruby/Rails changes in this PR (one or two sentences).

## File-Specific Suggestions

### 1. `path/to/file1.rb`

**Priority:** 🔴 SHOULD FIX
**Lines:** 15-20
**Checklist item:** [Ruby or Rails, and the item name, e.g. "Rails: N+1 queries"]

**Issue:** [Describe the problem]

**Current code:**

```ruby
# Quote the problematic code
```

**Suggested fix:**

```diff
--- path/to/file1.rb
+++ path/to/file1.rb
@@ -15,2 +15,2 @@
-# old code
+# new code
```

### 2. `db/migrate/20240101000000_add_index.rb`

**Priority:** 🟡 MEDIUM
**Lines:** 8-10
**Checklist item:** [item name]

**Issue:** [Describe the problem]

[Continue for each file...]

## Cross-Cutting Concerns

### Business Logic Spread Across Controllers

**Priority:** 🟡 MEDIUM
**Checklist item:** [item name]

Multiple files share the same problem:

**File:** `app/controllers/orders_controller.rb`

```diff
[diff here]
```

**File:** `app/controllers/invoices_controller.rb`

```diff
[diff here]
```

## Questions for PR Author

1. [Question about unclear logic or missing context]
2. [Question about test coverage]

## Conclusion

**Checklist result:** [No issues found ✅ | Minor issues ⚠️ | Issues need attention ❌]

**Blocking issues:** [None | List them]
````

---

## Priority Levels

Use emoji color-coding for priorities:

- 🟣 CRITICAL - Must fix before merge (security, data loss, breaking changes)
- 🔴 SHOULD FIX - Important issues (bugs, logic errors, significant problems)
- 🟡 MEDIUM - Improvements recommended (code quality, maintainability)
- 🟢 LOW - Nice to have (style, minor optimizations, suggestions)

## Sources

This checklist is a distilled summary of ideas from thoughtbot's [Ruby Science](https://github.com/thoughtbot/ruby-science) and [Testing Rails](https://github.com/thoughtbot/testing-rails), and from Chad Pytel and Tammer Saleh's *Rails AntiPatterns*. Consult them for the reasoning and worked examples behind each item.
