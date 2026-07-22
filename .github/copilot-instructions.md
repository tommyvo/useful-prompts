# Copilot Instructions for Useful Prompts

## Project Overview

This is a **reference library**, not a running application. It contains reusable prompts, instructions, and chat modes, hand-maintained in parallel across **four AI coding platforms**: GitHub Copilot, Cursor, Claude Code, and Opencode CLI. Files are authored in Markdown with YAML frontmatter and are deployed via shell scripts to each tool's config directory.

**CRITICAL:** No build/test/lint commands exist. This is a content repository that deploys via shell scripts.

## Repository Structure

```
├── Github Copilot/
│   ├── Prompt Files/      # Task-specific prompts (code review, commit messages, etc.)
│   │   └── deprecated/    # Retired prompts, kept for reference — never delete
│   ├── Instructions/      # Language/framework-specific coding guidelines that auto-apply
│   └── Chat Modes/        # Custom chat mode configurations
├── Cursor/
│   └── Skills/<name>/SKILL.md   # One folder per skill
├── Claude Code/
│   └── Skills/<name>/SKILL.md   # One folder per skill
├── opencode/               # Pre-converted versions for Opencode CLI
│   ├── agent/              # Chat-mode equivalents (agent: build / agent: plan)
│   ├── command/             # Task-prompt equivalents (agent: build)
│   └── README.md
├── install-copilot.sh      # Installs to ~/Library/Application Support/Code/User/prompts (macOS)
├── install-cursor.sh       # Installs to ~/.cursor/skills/
├── install-claude.sh       # Installs to ~/.claude/skills/
├── install-opencode.sh     # Installs to ~/.config/opencode/{agent,command}/
├── AGENTS.md                # Condensed agent-facing conventions
└── .github/                 # Repository configuration (this file)
```

**Deployment targets:**
- **GitHub Copilot (VS Code)**: `~/Library/Application Support/Code/User/prompts` (macOS) or equivalent on other platforms
- **Cursor**: `~/.cursor/skills/`
- **Claude Code**: `~/.claude/skills/`
- **Opencode CLI**: `~/.config/opencode/agent/` and `~/.config/opencode/command/`

## Architecture: Four Platforms, One Prompt Library

Every prompt/skill exists as **four parallel files** with (mostly) identical body content and platform-specific frontmatter.

### 1. GitHub Copilot Prompt Files (`Github Copilot/Prompt Files/*.prompt.md`) - On-Demand Task Automation
Invoked explicitly in Copilot Chat for specific one-time tasks.

**Frontmatter:**
```yaml
---
description: "Brief description"
agent: agent
---
```
Every current prompt file in this repo uses `agent: agent` (autonomous execution). There is no `mode:` key in use anywhere in this repo — if you encounter old docs or examples using `mode: agent` / `mode: ask`, treat them as stale and don't reproduce that pattern.

**Usage:** In Copilot Chat, type: `"Follow instructions in code-review.prompt.md"`

**Examples:**
- `code-review.prompt.md` - Runs `git diff HEAD`, generates priority-coded review (🟣🔴🟡🟢), auto-applies appropriate fixes
- `commit-message.prompt.md` - Auto-detects React/Rails/Generic project, generates structured commit message
- `gh-pr-code-review.prompt.md` - Fetches PR data via VS Code's GitHub PR extension tools (not `gh pr diff`, which crashes VS Code), provides unified diff suggestions
- `address-pr-comments.prompt.md` - Uses `gh` CLI + GitHub GraphQL API to find, fix, and resolve unresolved PR review threads

### 2. Instructions (`Github Copilot/Instructions/*.instructions.md`) - Auto-Applied Context
Language/framework-specific guidelines that automatically activate when editing matching files. GitHub Copilot only — there is no Cursor/Claude Code/Opencode equivalent in this repo.

**Frontmatter:**
```yaml
---
description: "Brief description"
applyTo: "**/*.ts"  # Glob pattern (string or array) to target specific file types
---
```

**⚠️ Warning:** Large instructions consume significant context window space. Use judiciously.

**Examples:**
- `typescript-5-es2022.instructions.md` - `applyTo: "**/*.ts"` - Target ES2022, avoid `any`, use discriminated unions
- `reactjs.instructions.md` - `applyTo: "**/*.jsx, **/*.tsx, **/*.js, **/*.ts, **/*.css, **/*.scss"` - Hooks patterns, component conventions
- `ruby-on-rails.instructions.md` - `applyTo: "**/*.rb"` - Rails conventions, RESTful patterns
- `ai-prompt-engineering-safety-best-practices.instructions.md` - `applyTo: ["*"]` - Safety framework, applies everywhere

### 3. Chat Modes (`Github Copilot/Chat Modes/*.chatmode.md`) - Specialized AI Personas
Custom chat mode configurations activated via the chat mode dropdown in Copilot Chat. Mirrored as Opencode agents.

**Frontmatter:**
```yaml
---
description: "Brief description"
tools: ['codebase', 'search', 'editFiles', ...]  # Enable specific VS Code capabilities
---
```

**Examples:**
- `Beast Mode 3.1.chatmode.md` - Autonomous problem-solving with extensive web research, iterates until problem is solved → mirrored as `opencode/agent/beast-mode.md` (`agent: build`)
- `Principal Engineer.chatmode.md` - Expert-level engineering guidance and technical leadership → mirrored as `opencode/agent/principal-engineer.md` (`agent: plan`, since it's advisory rather than task-executing)

### 4. Cursor Skills (`Cursor/Skills/<name>/SKILL.md`)
Cursor's skill format — one folder per skill, invoked as `/name` in Cursor chat.

**Frontmatter:**
```yaml
---
name: skill-name
description: >-
  What it does and when to use it (Cursor uses this for auto-invocation matching).
disable-model-invocation: true
---
```

### 5. Claude Code Skills (`Claude Code/Skills/<name>/SKILL.md`)
Same shape as Cursor skills, invoked as `/name` in Claude Code. Body content is usually a byte-identical copy of the Cursor version, since both run in a bash-capable agent and the underlying instructions (e.g. `gh` CLI usage) work unchanged.

**Naming exception:** the code-review skill is named `local-code-review` here (not `code-review`) because Claude Code has its own built-in `/code-review` command this would otherwise collide with.

### 6. Opencode Commands/Agents (`opencode/command/*.md`, `opencode/agent/*.md`)
Mirrors of the Copilot prompt files (→ `command/`) and chat modes (→ `agent/`).

**Frontmatter:**
```yaml
---
description: "Brief description"
agent: build   # or agent: plan for advisory/read-only chat modes
---
```

Opencode commands additionally support `{$ARGUMENTS}` for passing a single parameter (PR number/URL, file path) at invocation time — add a line like `**PR Number/URL:** {$ARGUMENTS}` near the top and reference it in the step that consumes it, when the prompt naturally takes such an argument.

## The Quadruple-Platform Rule: THE MOST CRITICAL RULE

**NEVER create or update just one version.** Every prompt/skill MUST be maintained in FOUR versions:

1. `Github Copilot/Prompt Files/name.prompt.md` (or `Chat Modes/Title Case.chatmode.md`)
2. `Cursor/Skills/name/SKILL.md`
3. `Claude Code/Skills/name/SKILL.md` (or `local-code-review` for the code-review skill)
4. `opencode/command/name.md` (or `opencode/agent/name.md` for chat-mode equivalents)

**The conversion between platforms:**
1. Copilot `agent: agent` → Cursor/Claude Code `name` + `description` + `disable-model-invocation: true` → Opencode `agent: build`
2. Body content is a mirror across all four — same steps, same examples, same output format
3. Deviate from an identical body ONLY when a tool genuinely can't do what another can (e.g. Copilot in VS Code must use the GitHub PR extension instead of `gh pr diff`) — that's the exception, document why inline, don't silently diverge
4. Add `{$ARGUMENTS}` in the Opencode version wherever the prompt takes a natural single argument

**Example:**
- `Github Copilot/Prompt Files/code-review.prompt.md` → `Cursor/Skills/code-review/SKILL.md` → `Claude Code/Skills/local-code-review/SKILL.md` → `opencode/command/code-review.md`
- `Github Copilot/Chat Modes/Beast Mode 3.1.chatmode.md` → `opencode/agent/beast-mode.md` (chat modes are Copilot + Opencode only; no Cursor/Claude Code equivalent exists in this repo today)

## Common Patterns

### Prompt File Structure

All prompt files follow this pattern:
```markdown
---
description: "Brief description"
agent: agent
---

# Title

## Goal
What the prompt achieves

## Process
Step-by-step instructions with **CRITICAL** markers for mandatory steps

## Instructions
Detailed guidance with numbered steps
```

## Critical Workflows

**Code Review Pattern (`code-review.prompt.md` / Cursor+Claude Code `code-review`/`local-code-review` / `opencode/command/code-review.md`):**
- **ALWAYS** start with `git diff HEAD` - this is mandatory, not optional
- Generate report with priority emoji coding: 🟣 CRITICAL, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW
- Auto-apply appropriate fixes (security, bugs, style) that are in scope
- Create todo lists to track progress using markdown checklist format
- Only include files in report that have specific suggestions (skip files with no issues)

**Commit Message Pattern (`commit-message.prompt.md`):**
- **ALWAYS** start with `git diff HEAD` to analyze changes
- Auto-detect project type from file structure:
  - React: Look for `.jsx`, `.tsx`, `package.json` with React deps
  - Rails: Look for `.rb`, `controllers/`, `models/`, `Gemfile`
- Use structured templates with sections (Components, API, Database, etc.)
- Output in fenced code blocks with 4 backticks (````) to preserve inner code blocks with 3 backticks
- Omit template sections that don't have relevant changes

**PR Review Pattern (`gh-pr-code-review.prompt.md`):**
- Use `gh` CLI to fetch PR data: `gh pr view`, `gh pr diff` (read-only operations only) — except the Copilot version, which routes through the GitHub PR extension instead of `gh pr diff` to avoid crashing VS Code
- Provide suggestions in unified diff format
- Include merge recommendations (Safe/Needs changes/Blocking issues)

**Address PR Comments Pattern (`address-pr-comments.prompt.md`):**
- Resolve the PR (from an argument or the current branch via `gh pr view`)
- Fetch unresolved review threads via `gh api graphql` (the REST API doesn't expose resolution state)
- Per thread: fix in-scope issues directly, or draft a reply for out-of-scope/disagreed concerns — **never post a reply without user approval**
- Run tests/lint before resolving anything
- Resolve fixed threads via a GraphQL `resolveReviewThread` mutation; post approved replies via the REST replies endpoint
- Read-only until the fix/reply step — no PR mutation happens without a decision per thread

**Gitignore Generation Pattern (`generate-gitignore.prompt.md`):**
- Check if `.gitignore` exists before overwriting
- Use the comprehensive template from this repo's `.gitignore` as-is
- No customization or project detection - always use full template

**Standup Update Pattern (`standup-update.prompt.md`):**
- Reads work log markdown files from user's workspace
- Generates Slack-formatted standup updates
- Extracts completed tasks, in-progress work, and blockers
- Formats output for direct paste into Slack channels

## Installation & Deployment

**Install Scripts (`install-copilot.sh`, `install-cursor.sh`, `install-claude.sh`, `install-opencode.sh`):**
- All four scripts show a file preview with NEW/MODIFIED indicators before installation
- Default confirmation is Yes (pressing Enter proceeds)
- `install-copilot.sh` copies `Github Copilot/Prompt Files/` and `Github Copilot/Chat Modes/` to `~/Library/Application Support/Code/User/prompts` (macOS)
- `install-cursor.sh` copies `Cursor/Skills/*/SKILL.md` to `~/.cursor/skills/`
- `install-claude.sh` copies `Claude Code/Skills/*/SKILL.md` to `~/.claude/skills/`
- `install-opencode.sh` copies `opencode/agent/` and `opencode/command/` to `~/.config/opencode/{agent,command}/`
- Scripts detect file conflicts and preserve unchanged files
- For GitHub Copilot: Restart VS Code after installation if prompts don't appear immediately; for Cursor/Claude Code, restart those tools too

## File Naming Conventions

- **Prompt Files**: `kebab-case.prompt.md`
- **Instructions**: `kebab-case.instructions.md`
- **Chat Modes**: `Title Case.chatmode.md` or `kebab-case.chatmode.md`
- **Cursor / Claude Code Skills**: `kebab-case/SKILL.md` (one folder per skill)
- **Opencode**: `kebab-case.md` under `agent/` or `command/`
- **Deprecated**: Move to `deprecated/` subfolder, don't delete

## When Creating New Prompts

1. **Use frontmatter** - Every file needs the frontmatter shape appropriate to its platform (see "Architecture" above)
2. **Include examples** - Show concrete examples from actual use cases
3. **Add critical markers** - Use `**CRITICAL**: DO NOT SKIP STEPS` for mandatory workflow steps
4. **Use emoji priority** - For reviews/reports: 🟣🔴🟡🟢 for severity levels
5. **Reference git commands** - Most prompts should start with `git diff HEAD` or similar
6. **Output format** - Specify whether output goes to chat or files
7. **Quadruple maintenance** - Create ALL FOUR versions:
   - Copilot: `Github Copilot/Prompt Files/name.prompt.md` with `agent: agent` (or `Github Copilot/Chat Modes/*.chatmode.md` with `tools: [...]`)
   - Cursor: `Cursor/Skills/name/SKILL.md` with `name` + `description` + `disable-model-invocation: true`
   - Claude Code: `Claude Code/Skills/name/SKILL.md`, same frontmatter shape as Cursor
   - Opencode: `opencode/command/name.md` with `agent: build` (or `opencode/agent/*.md` for chat-mode equivalents)
8. **Update docs** - **CRITICAL:** Add the new prompt to the root `README.md` tables (all four platform columns), `opencode/README.md`'s command/agent tables, and this file's pattern list. Users rely on these docs to find available prompts.

## Important Notes

- **No Build Commands**: This is a reference library - no `npm`, `bundle`, or test commands exist
- **Context Window**: Instructions (`.instructions.md`) auto-apply and consume context space - use judiciously; they exist only for GitHub Copilot
- **Git Integration**: Many prompts assume git repository context
- **Read-only Operations**: `gh-pr-code-review` uses ONLY read-only `gh` commands; `address-pr-comments` fixes code and posts replies/resolutions, but only after per-thread user approval for anything it decides not to fix
- **Autonomous Execution**: `agent: agent` (Copilot) / `agent: build` (Opencode) prompts should solve problems completely before returning control; `agent: plan` (Opencode) mirrors an advisory chat mode
- **Todo Lists**: Use markdown checklist format for tracking multi-step tasks
- **Deprecation**: Move deprecated files to `deprecated/` subfolder, don't delete them
