# Copilot Instructions for Useful Prompts

## Project Overview

This is a collection of reusable prompt files, instructions, and chat modes for GitHub Copilot and other AI coding assistants. The repository is designed to be used as a reference library, not a running application.

## Repository Structure

```
├── Prompt Files/          # Task-specific prompts for GitHub Copilot (code review, commit messages, etc.)
├── Instructions/          # Language/framework-specific coding guidelines that auto-apply
├── Chat Modes/            # Custom chat mode configurations for GitHub Copilot
├── opencode/              # Pre-converted versions for Opencode CLI
│   ├── agent/            # Autonomous agents (beast-mode, principal-engineer)
│   └── command/          # Task commands (code-review, commit-message, etc.)
└── .github/              # Repository configuration
```

## Key Concepts

### Three Types of AI Customizations

1. **Prompt Files** (`.prompt.md`) - Invoked on-demand via Copilot Chat for specific tasks
   - Use frontmatter: `mode: agent` (autonomous) or `mode: ask` (interactive)
   - Reference with: "Follow instructions in [filename].prompt.md"

2. **Instructions** (`.instructions.md`) - Auto-apply to files matching `applyTo` patterns
   - Use frontmatter: `applyTo: "**/*.ts"` to target specific file types
   - Automatically included in context when editing matching files
   - **Warning**: Large instructions consume significant context window space

3. **Chat Modes** (`.chatmode.md`) - Specialized AI personas/behaviors
   - Use frontmatter: `tools: [...]` to enable specific capabilities
   - Activated via chat mode dropdown in Copilot Chat

### Frontmatter Compatibility

**GitHub Copilot:**
- `mode: agent` - Autonomous task execution
- `mode: ask` - Interactive Q&A mode

**Opencode Alternative:**
- `agent: build` (equivalent to `mode: agent`)
- `agent: plan` (equivalent to `mode: ask`)

**Important:** Opencode files live in `opencode/` and are MIRRORS of the main prompt files with converted frontmatter. The structure differs:
- `Prompt Files/*.prompt.md` (Copilot) → `opencode/command/*.md` (Opencode)
- `Chat Modes/*.chatmode.md` (Copilot) → `opencode/agent/*.md` (Opencode)

When updating a prompt, update BOTH versions to keep them in sync.

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
