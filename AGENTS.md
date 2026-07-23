# Agent Guidelines for useful-prompts

## Project Type
Reference library of AI prompts - Markdown files with YAML frontmatter. NO build/test/lint commands exist. Files deploy via shell scripts.

## Build/Test Commands
N/A - This is a content repository, not a running application. No npm/bundle/test/lint commands.

## Repository Structure
Every prompt/skill/command is maintained in **four parallel copies**, one per platform:

| Directory | Platform | Format |
| --- | --- | --- |
| `Github Copilot/Prompt Files/` | GitHub Copilot | `kebab-case.prompt.md`, frontmatter: `description` + `agent: agent` |
| `Github Copilot/Instructions/` | GitHub Copilot (auto-apply) | `kebab-case.instructions.md`, frontmatter: `description` + `applyTo` |
| `Github Copilot/Chat Modes/` | GitHub Copilot | `Title Case.chatmode.md`, frontmatter: `description` + `tools: [...]` |
| `Cursor/Skills/<name>/SKILL.md` | Cursor | frontmatter: `name` + `description` + `disable-model-invocation: true` |
| `Claude Code/Skills/<name>/SKILL.md` | Claude Code | same shape as Cursor — usually a byte-identical copy |
| `opencode/command/` | Opencode (task automation) | frontmatter: `description` + `agent: build` (equivalent to Copilot's `agent: agent`) |
| `opencode/agent/` | Opencode (chat-mode equivalents) | frontmatter: `description` + `agent: build` or `agent: plan` |

**Note on GitHub Copilot frontmatter:** the key is `agent`, not `mode` — every current prompt file uses `agent: agent`. If you see `mode: agent` referenced anywhere, it's stale; don't reproduce it in new files.

## Code Style & Conventions
- **File naming**: `kebab-case.prompt.md` / `kebab-case.md` / `SKILL.md` under a `kebab-case/` folder; chat modes may use `Title Case.chatmode.md`
- **Frontmatter**: REQUIRED on ALL .md files — see the table above for the exact keys per platform
- **Quadruple-platform**: ALWAYS maintain ALL FOUR versions (Copilot, Cursor, Claude Code, Opencode) for every prompt/skill
- **Content sync**: Body content should be identical across all four versions except for frontmatter and, where genuinely necessary, tool-specific instructions (e.g. `gh-pr-code-review`'s Copilot version routes PR metadata through VS Code's GitHub PR extension instead of raw `gh` CLI calls, because `gh pr diff` crashes VS Code — that's the exception, not the norm)
- **Opencode arguments**: add a `{$ARGUMENTS}` slot in the Opencode version when the prompt naturally takes one argument (PR number/URL, file path)
- **Naming**: the local code review skill is named `local-code-review` (folder/file and slash command) across all four platforms, including Claude Code, to avoid colliding with Claude Code's own review tooling
- **Deprecation**: Move deprecated files to `deprecated/` subfolder (see `Github Copilot/Prompt Files/deprecated/`) - NEVER delete
- **Git patterns**: Most prompts start with `git diff HEAD` to analyze changes
- **Priority emojis**: Code reviews use 🟣 CRITICAL, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW
- **Documentation**: `README.md` MUST be kept in sync with every change to this repo — not just new prompts. Any change to file structure, scripts (e.g. `install-*.sh`), directory layout, or available commands requires a matching `README.md` update in the same change. When creating/updating a prompt specifically, also update the root `README.md` table, `opencode/README.md`, and this file for discoverability

## Deployment & Installation
- Copilot: `./scripts/install-copilot.sh` → `~/Library/Application Support/Code/User/prompts` (macOS)
- Cursor: `./scripts/install-cursor.sh` → `~/.cursor/skills/`
- Claude Code: `./scripts/install-claude.sh` → `~/.claude/skills/`
- Opencode: `./scripts/install-opencode.sh` → `~/.config/opencode/{agent,command}/`
- All platforms at once: `./scripts/install-all.sh` runs every `install-*.sh` script in sequence

## Importing New Skills (reverse direction)
The `import-*.sh` scripts (sharing helpers from `scripts/import-lib.sh`) go the other way: they scan a platform's global config dir for skills/prompts/agents not yet tracked in this repo, copy the new item into its canonical directory, and auto-generate best-effort ports to the other three platforms (frontmatter translated, body copied as-is).
- `./scripts/import-claude.sh` ← `~/.claude/skills/`
- `./scripts/import-cursor.sh` ← `~/.cursor/skills/`
- `./scripts/import-copilot.sh` ← `~/Library/Application Support/Code/User/prompts` (both `*.prompt.md` and `*.chatmode.md`)
- `./scripts/import-opencode.sh` ← `~/.config/opencode/{command,agent}/`

Auto-generated ports are a first draft only — always hand-review for tone, tool lists (chat mode/agent conversions need their `tools:`/`agent: build|plan` picked manually), and the platform-specific exceptions noted above, then update `README.md` and this file.

## See Also
- Full project documentation: `.github/copilot-instructions.md`
- Usage examples & architecture: `README.md`
- Opencode-specific details: `opencode/README.md`
