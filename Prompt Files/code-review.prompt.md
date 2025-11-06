---
description: "Local Code Review"
mode: agent
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

1. Correctness (high priority)
2. Security
3. Code clarity
4. Reusability
5. Consistency (low priority)

## Audience

1. The audience of this report is the PR reviewer. Please make sure it's easy to follow. Usually, the reviewer also doesn't have all the context.
2. Use emoji color-coding for priority levels:
   - 🟣 SHOULD FIX (purple) - Critical issues that must be addressed
   - 🔴 HIGH (red) - Important issues that should be addressed
   - 🟡 MEDIUM (yellow) - Nice-to-have improvements
   - 🟢 LOW (green) - Minor suggestions or style preferences

## Output

Output the report in Chat as markdown. You can use four backticks (````) for the outer markdown fenced code block, and three backticks for any fenced code blocks within the markdown.

## Report Format

The report should follow this format:

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
