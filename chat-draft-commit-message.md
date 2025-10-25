---
description: "Draft a commit message"
mode: ask
---
Draft a commit message for all the uncommitted changes we've made. You can use `git diff HEAD` to see the changes.
**Please specify the project type: React or Rails.**
Use the relevant template below. Omit any sections that don't have changes. If a project type wasn't specified, just try your best.

NOTE: If a project type is not specified, try to infer it from the files changed

---

## React Template

```
<feat||fix||chore>: <Brief title of change>

<Brief description of the change>

Components Changes:
- <Any Components changes>

API Integration:
- <Any changes to the API integration>

UI/UX Features:
- <Any changes to the UI/UX Features>

Testing:
- <Any testing updates>

<Any other changes>
```

---

## Rails Template

```
<feat||fix||chore>: <Brief title of change>

<Brief description of the change>

Database Changes:
- <Any database/migration changes>

API Changes:
- <Any overall API updates>

Controller Changes:
- <Any controller updates>

Model Changes:
- <Any model updates>

Testing:
- <Any testing updates>

<Any other changes>
```
