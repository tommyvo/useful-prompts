# Rule: Local Review Pull Request

## Goal

Provide a comprehensive report with suggestions for a code change that hasn't been committed yet. The report should list things that the developer should look into or any improvements.

## Process

1. **Get Changes via Git** Use `git diff HEAD` to retrieve relevant context for you to do the review. You can read existing files in the current directory for more context.
2. **Generate The Report:** Generate the comprehensive report in markdown format. List our improvements and rate them in terms of priority.

## Instructions

1. You are NOT supposed to update or modify the PR or make comments on my behalf. It's unacceptable.
2. You can also read the files in the current directory if you need more context for the review.
3. When you give suggestions, please provide concrete example(s).
4. When suggesting changes related to a code block, please quote the code block.
5. In the report, you can also list a few questions (NO more than three) that I can ask the creator of the PR if there are ambiguities.
6. In the report, please provide a brief conclusion whether if it's safe to merge this PR.
7. Save the report in the same directory.

## Output

Output the report in Chat.

## Report Format

1. The report should follow this format
```markdown

# Description
(Describe what this PR is about. Please follow this format:

1. A new model/controller/worker/component/etc ...
2. Refactoring of ....
3. ....

# Specific Suggestions
1. File: (file 1 path)
Priority: SHOULD FIX
Line 3-5:
(suggestion here)

Suggested changes: (if there are any)
(suggested changes here - use Unified Diff)

2. File: (file 2 path)
Priority: High (but optional)
Line 5-6:
(suggestion here)

3. File: (file 3 path)
Looks good. No changes needed
...

# General Suggestions
(If there are suggestions that are related to many files. List them here)

1. (Suggestion title here)
Priority: SHOULD FIX

File 1: (file path)
(Write what should be changed here)

File 2: (file_path)
(Write what should be changed here)

File 3: (file_path)
(Write what should be changed here)

2. (Suggestion title here)
Priority: LOW

File 1: (file path)
(Write what should be changed here)

File 2: (file_path)
(Write what should be changed here)

# Questions
(If there are questions for the PR owner, list them here)

# Conclusion
(is it safe to merge)
```

## What to Review
1. Correctness (high priority)
2. Security
3. Code clarity
4. Reusability
5. Consistency (low priority)

## Audience

1. The audience of this report is the PR reviewer. Please make sure it's easy to follow. Usually, the reviewer also doesn't have all the context.
2. Use emoji color-coding for priority (such as 🟣, 🔴, 🟡, 🟢). SHOULD FIX is purple, HIGH is red, MEDIUM is yellow, LOW is green.

## What to do after

After you've generated the report, please go ahead and apply any changes you think is appropriate. If there's something that needs a decision you can ask me, and then continue.

If you decide to not apply the suggested changes, please highlight and explain why.
