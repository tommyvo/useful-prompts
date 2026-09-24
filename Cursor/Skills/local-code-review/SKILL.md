---
name: local-code-review
description: Review uncommitted local code changes and provide a prioritized report with suggested fixes.
disable-model-invocation: true
---

# Local Code Review

## Goal

Provide a comprehensive report with suggestions for a code change that hasn't been committed yet. The report should list things that the developer should review, any optimizations that can be applied, and any security concerns.

## CRITICAL: MANDATORY FIRST STEP

**YOU MUST run `git diff HEAD` as your ABSOLUTE FIRST action before doing ANYTHING else.**

- DO NOT attempt to review code from context or memory
- DO NOT skip this step under any circumstances
- DO NOT proceed to the next step without running this command first
- DO NOT assume you know what changed

If you do not run `git diff HEAD` first, you are failing to follow instructions.

## Process

Follow these steps IN ORDER. DO NOT skip any step:

1. **STEP 1 - Get Changes via Git (MANDATORY):** Run `git diff HEAD` in the terminal to retrieve ALL uncommitted changes. This is your primary source of truth for what to review. You can read existing files in the current directory for additional context if needed.
2. **STEP 2 - Choose Review Mode:** Check the size of the diff with `git diff HEAD --shortstat`. If it touches more than 15 files or more than 800 changed lines, or the user asked for subagents, use **parallel subagents** as described in **Large Reviews: Parallel Subagents** below. Otherwise, or if the user asked not to use subagents, review it yourself in a single pass.
3. **STEP 3 - Generate The Report:** Generate the comprehensive report in markdown format. List improvements and rate them in terms of priority using the emoji system.
4. **STEP 4 - Apply Appropriate Fixes:** After generating the report, automatically apply any suggestions that are appropriate. Appropriate fixes are those that: (1) are in scope of the changes being made, and (2) would improve security, readability, fix obvious bugs, or address style/lint issues. Skip suggestions that don't relate to the changes being made or would require significant architectural decisions. **IMPORTANT:** If you decide to not apply any of the suggested changes, please highlight the ones that were skipped and explain why. Please do not save the report in the filesystem. You should only output to chat.

## Instructions

1. After generating the code review report, you will apply appropriate changes as described in the "What to do after" section below.
2. **Before applying changes, create a todo list** of all the suggestions that will be automatically applied, so the user can track the progress.
3. You can also read the files in the current directory if you need more context for the review.
4. When you give suggestions, please provide concrete example(s).
5. When suggesting changes related to a code block, please quote the code block.
6. In the report, you can also list a few questions if there are ambiguities.
7. In the report, please provide a brief conclusion whether if it's safe to merge this PR.
8. **Only include files in the report that have specific suggestions or issues.** Do not create sections for files that look good with no changes needed.

## Large Reviews: Parallel Subagents

Follow this section only if you chose parallel subagents in the "Choose Review Mode" step. If you chose a single pass, ignore this section and review the changes yourself.

**Split the work.** Launch one subagent per topic in **What to Review** below: Correctness, Security, Code clarity, Reusability, and Consistency. If only one unit applies, do not use subagents - review it yourself.

**Brief each subagent.** Subagents do not see this conversation, so each prompt must be self-contained. Include:

- Its unit: the topic name and description, or the full text of its checklist section, copied from this file
- The exact command to get the diff (with branch names or the PR number filled in) and the list of changed files
- The rules: review only the changed lines (and the code they directly affect); read other files only for context; do not modify files, post comments or reviews, or run scanners; never repeat secret values - mask them
- The return format below

**Return format.** Ask each subagent to return only a list of findings, each with: file, lines, priority (using this skill's priority emojis), topic or checklist item, the issue or risk, the quoted code, and a suggested fix as a unified diff. If it finds nothing, it returns exactly `No findings`.

**How to launch them on this platform.** Launch one general-purpose subagent per unit, all in parallel. Do not use the built-in Explore subagent, which is meant for searching rather than reviewing. Wait for all of them to return before merging.

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

## Follow-up Checklists

Some languages and frameworks have a dedicated checklist skill for a deeper second pass. Do NOT run these yourself; only suggest one when it applies.

| If the changes include... | Suggest |
| --- | --- |
| `.rb`, `.rake`, `.erb`, `Gemfile`, `db/migrate/` | `rails-review-checklist` (run `/rails-review-checklist`) |
| `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `next.config.*` | `react-review-checklist` (run `/react-review-checklist`) |
| `.tf`, `.tfvars`, `.hcl`, Atmos files (`atmos.yaml`, `stacks/`), `.github/workflows/`, `Dockerfile`, compose files, dependency manifests and lockfiles, `.env*`, credentials config, or code touching authentication, authorization, payments, file uploads, or personal data | `security-review-checklist` (run `/security-review-checklist`) |

If the changes match more than one row (for example, a Rails API and a Next.js frontend), suggest each matching checklist. For the language rows, only suggest a checklist when the change is non-trivial (new or changed logic, components, models, controllers, migrations, or tests), and skip it for docs, config-only changes, renames, formatting, or very small changes. The security row is the exception: suggest it even for small changes (a one-line IAM policy or security group change can matter more than a large refactor), skipping it only for documentation- or formatting-only changes.

## Audience

1. The audience of this report is the PR reviewer. Please make sure it's easy to follow. Usually, the reviewer also doesn't have all the context.
2. Use emoji color-coding for priority levels:
   - 🟣 SHOULD FIX (purple) - Critical issues that must be addressed
   - 🔴 HIGH (red) - Important issues that should be addressed
   - 🟡 MEDIUM (yellow) - Nice-to-have improvements
   - 🟢 LOW (green) - Minor suggestions or style preferences

## Report Format

The report should follow this format:

Output the report as normal rendered markdown following the structure below. The code fence below only delimits the template - do not include it in your output or wrap your report in a code fence.

````markdown
# Description

(Describe what this change is about. Examples:)

- A new model/controller/worker/component/etc.
- Refactoring of [specific component/module]
- Bug fix for [specific issue]
- Performance optimization for [specific area]

# Specific Suggestions

1. File: (file 1 path)
   Priority: 🟣 SHOULD FIX
   Line 3-5:
   (suggestion here)

Suggested changes: (if there are any)
(suggested changes here - use Unified Diff)

2. File: (file 2 path)
   Priority: 🔴 HIGH
   Line 5-6:
   (suggestion here)

(Note: Only include files that have specific suggestions. Omit files with no issues.)

# General Suggestions

(If there are suggestions that are related to many files. List them here)

1. (Suggestion title here)
   Priority: 🟣 SHOULD FIX

File 1: (file path)
(Write what should be changed here)

File 2: (file_path)
(Write what should be changed here)

File 3: (file_path)
(Write what should be changed here)

2. (Suggestion title here)
   Priority: 🟢 LOW

File 1: (file path)
(Write what should be changed here)

File 2: (file_path)
(Write what should be changed here)

# Questions

(If there are questions for the PR owner, list them here)

# Conclusion

- Overall code quality: (Good/Needs Work/Requires Significant Changes)
- Blocking issues: (None/List them)
- Recommendation: (Safe to merge/Merge after fixes/Needs discussion)

# Suggested Follow-ups

(Optional. Omit this section if no follow-up applies. Include only the lines for checklists that match the changes.)

- Ruby/Rails changes detected - consider running `/rails-review-checklist` for a Ruby/Rails smell, antipattern, and testing check.
- JavaScript/TypeScript changes detected - consider running `/react-review-checklist` for a TypeScript, React, Next.js, and testing check.
- Security-sensitive changes detected - consider running `/security-review-checklist` for a security check (application, secrets, supply chain, infrastructure, CI/CD, and SOC 2/GDPR if requested).
````
