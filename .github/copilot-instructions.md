# Copilot Instructions for Useful Prompts

## Project Overview

This is a **reference library**, not a running application. It contains reusable prompt files, instructions, and chat modes for GitHub Copilot and Opencode CLI. Files are authored in Markdown with YAML frontmatter and are deployed via shell scripts to user config directories.

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

## Dual-Platform Architecture

Files must be maintained in TWO versions for cross-platform compatibility:

**GitHub Copilot (VS Code):**
- `Prompt Files/*.prompt.md` with `mode: agent`
- `Chat Modes/*.chatmode.md` with `tools: [...]`

**Opencode CLI:**
- `opencode/command/*.md` with `agent: build` (equivalent to `mode: agent`)
- `opencode/agent/*.md` with `agent: build` (chat mode equivalents)

**CRITICAL:** When creating or updating any prompt/chat mode, update BOTH versions to keep them in sync. The Opencode versions are MIRRORS with converted frontmatter, not separate implementations.

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

### Critical Workflows

**Code Review Pattern:**
- ALWAYS use `git diff HEAD` to get uncommitted changes
- Generate report with priority emoji coding: 🟣 CRITICAL, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW
- Auto-apply appropriate fixes (security, bugs, style)
- Create todo lists to track progress

**Commit Message Pattern:**
- ALWAYS use `git diff HEAD` to analyze changes
- Auto-detect project type (React/Rails/Generic) from file structure
- Use structured templates with sections (Components, API, Database, etc.)
- Output in fenced code blocks with 4 backticks to preserve inner code blocks

**PR Review Pattern:**
- Use `gh` CLI to fetch PR data (`gh pr view`, `gh pr diff`)
- Provide suggestions in unified diff format
- Include merge recommendations (Safe/Needs changes/Blocking issues)

## File Naming Conventions

- **Prompt Files**: `kebab-case.prompt.md`
- **Instructions**: `kebab-case.instructions.md`
- **Chat Modes**: `Title Case.chatmode.md` or `kebab-case.chatmode.md`
- **Deprecated**: Move to `deprecated/` subfolder, don't delete

## When Creating New Prompts

1. **Use frontmatter** - All markdown files need YAML frontmatter with `description` and `mode`/`agent`
2. **Include examples** - Show concrete examples from actual use cases
3. **Add critical markers** - Use `**CRITICAL**: DO NOT SKIP STEPS` for mandatory workflow steps
4. **Use emoji priority** - For reviews/reports: 🟣🔴🟡🟢 for severity levels
5. **Reference git commands** - Most prompts should start with `git diff HEAD` or similar
6. **Output format** - Specify whether output goes to chat or files
7. **Dual maintenance** - Create both Copilot version AND Opencode version:
   - Copilot: `Prompt Files/name.prompt.md` with `mode: agent`
   - Opencode: `opencode/command/name.md` with `agent: build`
   - Chat modes go to `Chat Modes/*.chatmode.md` and `opencode/agent/*.md`
8. **Update README.md** - Add new prompts to the main README table for discoverability

## Important Notes

- **Context Window**: Instructions auto-apply and consume context space - use judiciously
- **Git Integration**: Many prompts assume git repository context
- **Read-only Operations**: PR review prompts use ONLY read-only `gh` commands
- **Autonomous Execution**: "Agent" mode prompts should solve problems completely before returning control
- **Todo Lists**: Use markdown checklist format for tracking multi-step tasks

## Testing New Prompts

1. Test with GitHub Copilot in VS Code
2. Verify frontmatter is valid YAML
3. Check that `applyTo` patterns work for instructions
4. Ensure examples reference real files from this repo
5. Update main README.md table when adding new prompts
6. Convert and test the Opencode version if creating a prompt file or chat mode
