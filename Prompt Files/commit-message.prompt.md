---
description: "Draft a commit message"
mode: agent
---

Draft a commit message for all the uncommitted changes. Use `git diff HEAD` to see the changes.

**Instructions:**
- If I specify "React" or "Rails", use the corresponding template below
- If I don't specify a project type, try to infer it from the file extensions and structure:
  - React: Look for .jsx, .tsx files, component folders, package.json with React dependencies
  - Rails: Look for .rb files, controllers/, models/, db/migrate/ folders, Gemfile
- If the project type cannot be determined, provide a generic commit message with a clear description of changes
- Omit any template sections that don't have relevant changes

---

## React Template

```
<feat|fix|chore>: <Brief title of change>

<Brief description of the change>

Components Changes:
- <Any Components changes>

API Integration:
- <Any changes to the API integration>

UI/UX Features:
- <Any changes to the UI/UX Features>

Testing:
- <Any testing updates>

Other Changes:
- <Any other changes>
```

---

## Rails Template

```
<feat|fix|chore>: <Brief title of change>

<Brief description of the change>

Database Changes:
- <Any database/migration changes>

API Changes:
- <Any overall API updates>

Response Body Changes:
- <Any changes to API response bodies>

Controller Changes:
- <Any controller updates>

Model Changes:
- <Any model updates>

Testing:
- <Any testing updates>

Other Changes:
- <Any other changes>
```

---

## Generic Template (when project type is unclear)

```
<feat|fix|chore>: <Brief title of change>

<Brief description of the change>

Changes:
- <List key changes by file or functionality>

Impact:
- <Any notable impacts or side effects>
```
