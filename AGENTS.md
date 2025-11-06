# Agent Guidelines for useful-prompts

## Project Type
Reference library of AI prompts (Markdown files with YAML frontmatter). NOT a running application - no build/test/lint commands.

## Key Rules from .github/copilot-instructions.md
- This is a REFERENCE LIBRARY - files are deployed via shell scripts, not executed directly
- ALWAYS maintain DUAL versions: GitHub Copilot (`Prompt Files/`, `Chat Modes/`) AND Opencode (`opencode/command/`, `opencode/agent/`)
- NEVER delete deprecated files - move to `deprecated/` subfolder instead
- ALL markdown files MUST have YAML frontmatter with `description` and `mode`/`agent` fields
- Use `git diff HEAD` extensively in prompt workflows for code review and commit message generation

## File Structure & Naming
- Prompt Files: `kebab-case.prompt.md` with `mode: agent` frontmatter
- Chat Modes: `Title Case.chatmode.md` with `tools: [...]` frontmatter
- Instructions: `kebab-case.instructions.md` with `applyTo: "glob pattern"` frontmatter
- Opencode equivalents: Strip `.prompt` and use `agent: build` instead of `mode: agent`

## Critical Workflows
- Code reviews use priority emoji coding: 🟣 CRITICAL, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW
- Commit messages auto-detect project type (React/Rails/Generic) and use structured templates
- PR reviews use read-only `gh` CLI commands only, provide unified diff format suggestions
- When creating/updating prompts, MUST update README.md table for discoverability

## Deployment
- GitHub Copilot: `./install-copilot.sh` → `~/Library/Application Support/Code/User/prompts` (macOS)
- Opencode: `./install-opencode.sh` → `~/.config/opencode/agent/` and `~/.config/opencode/command/`
