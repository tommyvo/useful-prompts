---
description: 'Draft a commit message for Rails project'
mode: ask
---
> **DEPRECATED: Use chat-draft-commit-message.md instead.**
# Chat commit message - Rails

Draft a commit message of for all the uncommitted changes we've made. You can use `git diff HEAD` to see the changes. Below is a template I'd like you to use.

You can omit any sections that didn't doesn't have any changes.

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
