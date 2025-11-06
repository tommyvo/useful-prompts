# Copilot Instructions for Useful Prompts

## Project Overview

This is a **reference library**, not a running application. It contains reusable prompt files, instructions, and chat modes for GitHub Copilot and Opencode CLI. Files are authored in Markdown with YAML frontmatter and are deployed via shell scripts to user config directories.

**CRITICAL:** No build/test/lint commands exist. This is a content repository that deploys via shell scripts.

## Repository Structure

```
├── Prompt Files/          # Task-specific prompts for GitHub Copilot (code review, commit messages, etc.)
├── Instructions/          # Language/framework-specific coding guidelines that auto-apply
├── Chat Modes/            # Custom chat mode configurations for GitHub Copilot
├── opencode/              # Pre-converted versions for Opencode CLI
│   ├── agent/            # Chat mode equivalents (beast-mode, principal-engineer)
│   └── command/          # Task command equivalents (code-review, commit-message, etc.)
├── install-copilot.sh    # Installs to ~/Library/Application Support/Code/User/prompts (macOS)
├── install-opencode.sh   # Installs to ~/.config/opencode/{agent,command}/ (cross-platform)
└── .github/              # Repository configuration
```

**Deployment targets:**
- **GitHub Copilot (VS Code)**: `~/Library/Application Support/Code/User/prompts` (macOS) or equivalent on other platforms
- **Opencode CLI**: `~/.config/opencode/agent/` and `~/.config/opencode/command/`

## Architecture: Three Types of AI Customizations

### 1. Prompt Files (`.prompt.md`) - On-Demand Task Automation
Invoked explicitly in Copilot Chat for specific one-time tasks.

**Frontmatter:**
```yaml
---
description: "Brief description"
mode: agent  # Autonomous execution (or `mode: ask` for interactive Q&A)
---
```

**Usage:** In Copilot Chat, type: `"Follow instructions in code-review.prompt.md"`

**Examples:**
- `code-review.prompt.md` - Runs `git diff HEAD`, generates priority-coded review (🟣🔴🟡🟢), auto-applies appropriate fixes
- `commit-message.prompt.md` - Auto-detects React/Rails/Generic project, generates structured commit message
- `gh-pr-code-review.prompt.md` - Uses `gh` CLI to fetch PR data, provides unified diff suggestions

### 2. Instructions (`.instructions.md`) - Auto-Applied Context
Language/framework-specific guidelines that automatically activate when editing matching files.

**Frontmatter:**
```yaml
---
description: "Brief description"
applyTo: "**/*.ts"  # Glob pattern to target specific file types
---
```

**⚠️ Warning:** Large instructions consume significant context window space. Use judiciously.

**Examples:**
- `typescript-5-es2022.instructions.md` - `applyTo: "**/*.ts"` - Target ES2022, avoid `any`, use discriminated unions
- `reactjs.instructions.md` - `applyTo: "**/*.jsx,**/*.tsx"` - Hooks patterns, component conventions
- `ruby-on-rails.instructions.md` - `applyTo: "**/*.rb"` - Rails conventions, RESTful patterns

### 3. Chat Modes (`.chatmode.md`) - Specialized AI Personas
Custom chat mode configurations activated via the chat mode dropdown in Copilot Chat.

**Frontmatter:**
```yaml
---
description: "Brief description"
tools: ['codebase', 'search', 'editFiles', ...]  # Enable specific VS Code capabilities
---
```

**Examples:**
- `Beast Mode 3.1.chatmode.md` - Autonomous problem-solving with extensive web research, iterates until problem is solved
- `Principal Engineer.chatmode.md` - Expert-level engineering guidance and technical leadership

## Dual-Platform Architecture: THE MOST CRITICAL RULE

**NEVER create or update just one version.** Files MUST be maintained in TWO versions for cross-platform compatibility:

**GitHub Copilot (VS Code):**
- `Prompt Files/*.prompt.md` with `mode: agent` frontmatter
- `Chat Modes/*.chatmode.md` with `tools: [...]` frontmatter

**Opencode CLI:**
- `opencode/command/*.md` with `agent: build` (equivalent to `mode: agent`)
- `opencode/agent/*.md` with `agent: build` (chat mode equivalents)

**The conversion is simple:**
1. Copilot → Opencode: Strip `.prompt` or `.chatmode` from filename, change `mode: agent` to `agent: build`
2. Opencode versions are MIRRORS with converted frontmatter, not separate implementations
3. Content in both files should be identical except for frontmatter

**Example:**
- `Prompt Files/code-review.prompt.md` → `opencode/command/code-review.md`
- `Chat Modes/Beast Mode 3.1.chatmode.md` → `opencode/agent/beast-mode.md`

## Common Patterns

### Prompt File Structure

All prompt files follow this pattern:
```markdown
---
description: "Brief description"
mode: agent
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

**Code Review Pattern (`code-review.prompt.md`):**
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
- Use `gh` CLI to fetch PR data: `gh pr view`, `gh pr diff` (read-only operations only)
- Provide suggestions in unified diff format
- Include merge recommendations (Safe/Needs changes/Blocking issues)

**Gitignore Generation Pattern (`generate-gitignore.prompt.md`):**
- Check if `.gitignore` exists before overwriting
- Use the comprehensive template from this repo's `.gitignore` as-is
- No customization or project detection - always use full template

## File Naming Conventions

- **Prompt Files**: `kebab-case.prompt.md`
- **Instructions**: `kebab-case.instructions.md`
- **Chat Modes**: `Title Case.chatmode.md` or `kebab-case.chatmode.md`
- **Deprecated**: Move to `deprecated/` subfolder, don't delete

## When Creating New Prompts

1. **Use frontmatter** - All markdown files need YAML frontmatter with `description` and `mode`/`agent` fields
2. **Include examples** - Show concrete examples from actual use cases
3. **Add critical markers** - Use `**CRITICAL**: DO NOT SKIP STEPS` for mandatory workflow steps
4. **Use emoji priority** - For reviews/reports: 🟣🔴🟡🟢 for severity levels
5. **Reference git commands** - Most prompts should start with `git diff HEAD` or similar
6. **Output format** - Specify whether output goes to chat or files
7. **Dual maintenance** - Create both Copilot version AND Opencode version:
   - Copilot: `Prompt Files/name.prompt.md` with `mode: agent`
   - Opencode: `opencode/command/name.md` with `agent: build`
   - Chat modes: `Chat Modes/*.chatmode.md` and `opencode/agent/*.md`
8. **Update README.md** - Add new prompts to the main README table for discoverability

## Important Notes

- **No Build Commands**: This is a reference library - no `npm`, `bundle`, or test commands exist
- **Context Window**: Instructions (`.instructions.md`) auto-apply and consume context space - use judiciously
- **Git Integration**: Many prompts assume git repository context
- **Read-only Operations**: PR review prompts use ONLY read-only `gh` commands
- **Autonomous Execution**: "Agent" mode prompts should solve problems completely before returning control
- **Todo Lists**: Use markdown checklist format for tracking multi-step tasks
- **Deprecation**: Move deprecated files to `deprecated/` subfolder, don't delete them
