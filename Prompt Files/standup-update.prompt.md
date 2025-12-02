---
description: "Generate a Slack standup update from a work log markdown file"
mode: agent
---

# Standup Update Generator

## Goal
Generate a formatted Slack standup update by summarizing entries from the last working day and current day (if present) in a work log markdown file.

## Process

**CRITICAL: DO NOT SKIP STEPS**

1. **Locate the work log file**
   - If a file path is provided by the user, resolve it relative to the workspace root
   - Handle file paths with spaces correctly (e.g., `Work/Soraban/Work Log.md`)
   - If the file is not found, try searching the workspace for files matching the pattern
   - If no file path is provided, ask the user for the location of their work log markdown file
   - Read the entire file to understand the structure

2. **Identify relevant dates**
   - Find today's date (current date)
   - Find the last working day entry (most recent entry before today, excluding weekends/holidays)
   - If there's an entry for today, include it as well

3. **Extract and summarize entries**
   - Extract bullet points from the last working day
   - Extract bullet points from today (if present)
   - **Summarize and consolidate**: Group related tasks, remove redundant details, focus on outcomes
   - Convert past entries to past tense
   - Keep today's entries in present tense
   - Keep summaries concise (1-2 levels of nesting max)

4. **Format for Slack**
   - Use 4 spaces for indentation (not 2 spaces)
   - Preserve markdown formatting (links, inline code with backticks)
   - Order dates in reverse chronological order (today first, then last working day)
   - Each date should be a heading followed by its bullet points

## Instructions

### Step 1: Read the Work Log

Read the provided markdown file completely to understand its structure. The file contains dated entries in the format `MM/DD/YYYY` followed by bullet points describing work activities.

### Step 2: Extract Relevant Entries

1. Identify today's date
2. Find the most recent entry before today (last working day)
3. If there's an entry for today, note it
4. Extract all bullet points and sub-bullets from these entries

### Step 3: Summarize Content

**CRITICAL: This is a summary, not a copy-paste**

1. **Consolidate related tasks**: If multiple bullets describe parts of the same work, combine them
2. **Focus on outcomes**: Emphasize what was accomplished, not every implementation detail
3. **Remove noise**: Skip overly technical details, internal ticket references, or verbose explanations
4. **Limit nesting**: Keep to 1-2 levels of bullet points maximum
5. **Keep it scannable**: Each top-level bullet should be a distinct area of work

**Examples of summarization:**

Before (verbose):
- worked on user authentication bug
    - investigated the session timeout issue
    - found the problem in middleware
    - fixed the bug in auth.rb
    - added tests for the fix
    - deployed to staging

After (summarized):
- fixed user authentication session timeout bug and deployed to staging

Before (redundant):
- attended standup meeting
- attended sprint planning
- had 1:1 with manager
- attended architecture review

After (consolidated):
- attended team meetings (standup, sprint planning, architecture review)

### Step 4: Convert Tense

- **For past entries (last working day)**: Convert verbs to past tense
  - "create" → "created"
  - "work on" → "worked on"
  - "start" → "started"
  - "look into" → "looked into"
  - "have meeting" → "had meeting"

- **For today's entries**: Keep verbs in present tense
  - "create" → "create"
  - "work on" → "work on"
  - "start" → "start"

### Step 5: Format Output

Generate markdown output with these specifications:

1. **Indentation**: Use 4 spaces per level (required for Slack formatting)
2. **Date format**: Use ONLY `MM/DD/YYYY` - NO labels like "(today)" or "(last working day)"
3. **Order**: Newest date first
4. **Preserve**: Links, inline code, nested structure
5. **Remove**: Any wiki-style links like `[[...]]`
6. **No commentary**: Do not add any explanatory text before or after the code block

### Output Format Example

```markdown
12/01/2025

- have meeting to go over plan to migrate from Heroku to AWS on production
    - this should include going over what production environment cleanup
- start prework for AWS migration
    - get AWS production ready for testing
        - make sure we have https://newprod.soraban.dev available and have AWS production service point to it

11/26/2025

- created CloudWatch alarms based on Sidekiq QueueLength for each of our queues, and used this to finally define scaling policies
    - added these CloudWatch alarms and scaling policies to `soraban-infra`
        - PR: https://github.com/Soraban/soraban-infra/pull/31
```

### Step 6: Present the Output

**CRITICAL: Output ONLY the code block, nothing else**

1. Start with four backticks followed by `markdown`: ````markdown
2. Output ONLY the formatted dates and bullet points
3. End with four backticks: ````
4. Do NOT include any text before or after the code block
5. Do NOT include processing notes or explanations in the output

## Important Notes

- **4 spaces for indentation**: This is critical for proper Slack formatting
- **Tense consistency**: Past entries must be past tense, today's entries stay present tense
- **Preserve structure**: Maintain the hierarchical nesting of bullet points
- **Links and code**: Keep all URLs and inline code formatting intact
- **Clean output**: Remove any wiki-style links or internal references that aren't relevant for standup
