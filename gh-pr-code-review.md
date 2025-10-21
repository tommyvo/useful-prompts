# Rule: Review Pull Request

<goal>
To provide a comprehensive report with suggestions for a Pull Request using `gh` commands. The report should list things that the developer should look into or any improvements. Finally, save the report in `REVIEW.md` in the same directory.
</goal>

<process>
1. **Receive Initial Prompt:** The user provides the `pull_request_id`. If user doesn't provide the `pull_request_id`, try to retrieve it based on the current branch name.
2. **Use gh Commands:** Use `gh` commands to retrieve relevant context for you to do the review. You can read existing files in the current directory for more context.
3. **Generate The Report:** Generate the comprehensive report in markdown format. List our improvements and rate them in terms of priority.
</process>

<instructions>
1. You are NOT supposed to use `gh` commands that update or modify the PR or make comments on my behalf. It's unacceptable. You only use the `gh` commands to get context for the review. Here are some examples of these commands that you can use:
    ```bash
    gh pr view <pull_request_id>
    gh pr diff <pull_request_id>
    gh pr checks
    ```
2. You can also read the files in the current directory if you need more context for the review.
3. When you give suggestions, please provide concrete examples. Please use unified diff format in markdown code blocks so that we can review and apply the changes more easily. See <unifiedDiffInstructions> section below.
4. When suggesting changes related to a code block, please quote the code block.
5. In the report, you can also list a few questions (NO more than three) that I can ask the creator of the PR if there are ambiguities.
6. In the report, please provide a brief conclusion whether if it's safe to merge this PR and follow the format in <reportFormat> section.
7. Save the report in the same directory.
</instructions>

<unifiedDiffInstructions>
Return edits similar to unified diffs that `diff -U0` would produce.

Make sure you include the first 2 lines with the file paths.
Don't include timestamps with the file paths.
Do not use any file path prefixes, just use --- path/to/file and +++ path/to/file.

Start each hunk of changes with a `@@` line.

The user's patch tool needs CORRECT patches that apply cleanly against the current contents of the file!
Code can start with line number prefixes for reference (e.g., `1: def example():`), but your output MUST NOT include these line number prefixes.
Think carefully and make sure you include and mark all lines that need to be removed or changed as `-` lines.
Make sure you mark all new or modified lines with `+`.
Don't leave out any lines or the diff patch won't apply correctly.

Indentation matters in the diffs!

Start a new hunk for each section of the file that needs changes.

Only output hunks that specify changes with `+` or `-` lines.

Output hunks in whatever order makes the most sense.
Hunks don't need to be in any particular order.

When editing a function, method, loop, etc use a hunk to replace the *entire* code block.
Delete the entire existing version with `-` lines and then add a new, updated version with `+` lines.
This will help you generate correct code and correct diffs.

To move code within a file, use 2 hunks: 1 to delete it from its current location, 1 to insert it in the new location.
To make a new file, show a diff from `--- /dev/null` to `+++ path/to/new/file.ext`.

</unifiedDiffInstructions>

<outputFormat>
**Format:** `REVIEW.md`
</outputFormat>

<reportFormat>

```markdown
# PR URL
https://github.com/<repo>/pull/<pull_request_id>

# Description
(Describe what this PR is about. Please follow this format:

This PR adds/removes/changes ....

1. A new model/controller/worker/component/etc ...
2. Refactoring of ....
3. ....

# Specific Suggestions
1. File: (file 1 path)
Priority: SHOULD FIX
Line 3-5:
(suggestion here)

Suggested changes: (if there are any)
(suggested changes here - use unified diff)


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

File 1: (use unified diff)
(Write what should be changed here)

File 2: (use unified diff)
(Write what should be changed here)

File 3: (use unified diff)
(Write what should be changed here)

2. (Suggestion title here)
Priority: LOW

File 1: (use unified diff)
(Write what should be changed here)

File 2: (use unified diff)
(Write what should be changed here)

# Questions
(If there are questions for the PR owner, list them here)

# Conclusion
(is it safe to merge)
```

</reportFormat>

<whatToReview>
1. Correctness (high priority)
2. Security
3. Code clarity
4. Reusability
5. Consistency (low priority)
</whatToReview>

<targetAudience>
1. The audience of this report is the PR reviewer. Please make sure it's easy to follow. Usually, the reviewer also doesn't have all the context.
2. Use emoji color-coding for priority (such as 🟣, 🔴, 🟡, 🟢). SHOULD FIX is purple, HIGH is red, MEDIUM is yellow, LOW is green.
</targetAudience>
