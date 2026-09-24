---
description: "Local Code Review"
agent: agent
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
2. **STEP 2 - Generate The Report:** Generate the comprehensive report in markdown format. List improvements and rate them in terms of priority using the emoji system.
3. **STEP 3 - Apply Appropriate Fixes:** After generating the report, automatically apply any suggestions that are appropriate. Appropriate fixes are those that: (1) are in scope of the changes being made, and (2) would improve security, readability, fix obvious bugs, or address style/lint issues. Skip suggestions that don't relate to the changes being made or would require significant architectural decisions. **IMPORTANT:** If you decide to not apply any of the suggested changes, please highlight the ones that were skipped and explain why. Please do not save the report in the filesystem. You should only output to chat.

## Instructions

1. After generating the code review report, you will apply appropriate changes as described in the "What to do after" section below.
2. **Before applying changes, create a todo list** of all the suggestions that will be automatically applied, so the user can track the progress.
3. You can also read the files in the current directory if you need more context for the review.
4. When you give suggestions, please provide concrete example(s).
5. When suggesting changes related to a code block, please quote the code block.
6. In the report, you can also list a few questions if there are ambiguities.
7. In the report, please provide a brief conclusion whether if it's safe to merge this PR.
8. **Only include files in the report that have specific suggestions or issues.** Do not create sections for files that look good with no changes needed.

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
