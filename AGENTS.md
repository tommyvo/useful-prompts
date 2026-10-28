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
| `Cursor/Skills/<name>/SKILL.md` | Cursor | frontmatter: `name` + `description` + `disable-model-invocation: true` |
| `Claude Code/Skills/<name>/SKILL.md` | Claude Code | same shape as Cursor — usually a byte-identical copy |
| `opencode/command/` | Opencode (task automation) | frontmatter: `description` + `agent: build` (equivalent to Copilot's `agent: agent`) |

**Note on GitHub Copilot frontmatter:** the key is `agent`, not `mode` — every current prompt file uses `agent: agent`. If you see `mode: agent` referenced anywhere, it's stale; don't reproduce it in new files.

## Code Style & Conventions
- **File naming**: `kebab-case.prompt.md` / `kebab-case.md` / `SKILL.md` under a `kebab-case/` folder
- **Frontmatter**: REQUIRED on ALL .md files — see the table above for the exact keys per platform
- **Quadruple-platform**: ALWAYS maintain ALL FOUR versions (Copilot, Cursor, Claude Code, Opencode) for every prompt/skill
- **Content sync**: Body content should be identical across all four versions except for frontmatter and, where genuinely necessary, tool-specific instructions. The `gh-pr-*` skills fetch PR data with the `gh` CLI only on every platform (no GitHub MCP or VS Code GitHub PR extension tools, which don't work reliably); Copilot's versions additionally avoid `gh pr diff`, which crashes VS Code, and diff with `git diff origin/<base>...origin/<head>` instead. The review and checklist skills' "How to launch them on this platform" paragraph (under "Large Reviews: Parallel Subagents") is also per-platform, because each tool launches subagents differently: Claude Code's `Agent` tool, Cursor's subagents, Copilot's `runSubagent` tool, and opencode's Task tool with the `general` subagent. Don't add `tools:` frontmatter to Copilot prompt files to enable subagents: it replaces the default tool list. The security checklists' "Independent Verification" step reuses that same launch paragraph, so it needs no per-platform text of its own
- **Shared bodies**: `security-review-checklist` and `gh-pr-security-review-checklist` share one body from "Review Method" through "Suggested Scanners" (including "Wildcard Questions"), plus "Severity Guide" and "Sources"; keep those sections identical across both variants and all four platforms
- **Attribution**: when a skill adapts ideas from an external project, credit it (with its license and copyright line) in the skill's `## Sources` section and in the README's Acknowledgments, e.g. the security checklists credit Cloudflare's [security-audit skill](https://github.com/cloudflare/security-audit-skill) (MIT License). Paraphrase and adapt; don't copy text wholesale
- **Opencode arguments**: add a `{$ARGUMENTS}` slot in the Opencode version when the prompt naturally takes one argument (PR number/URL, file path)
- **Naming**: the local code review skill is named `local-code-review` (folder/file and slash command) across all four platforms, including Claude Code, to avoid colliding with Claude Code's own review tooling
- **Deprecation**: Move deprecated files to `deprecated/` subfolder (see `Github Copilot/Prompt Files/deprecated/`) - NEVER delete. Retired chat modes/agents (Beast Mode, Principal Engineer) live in the top-level `deprecated/` tree, which mirrors their original paths (`deprecated/Github Copilot/Chat Modes/`, `deprecated/opencode/agent/`). The install and import scripts no longer handle chat modes or agents, so nothing under it is installed
- **Git patterns**: Most prompts start with `git diff HEAD` to analyze changes
- **Priority emojis**: Code reviews use 🟣 CRITICAL, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW
- **Documentation**: `README.md` MUST be kept in sync with every change to this repo — not just new prompts. Any change to file structure, scripts (e.g. `install-*.sh`), directory layout, or available commands requires a matching `README.md` update in the same change. When creating/updating a prompt specifically, also update the root `README.md` table, `opencode/README.md`, and this file for discoverability

## Deployment & Installation
- Copilot: `./scripts/install-copilot.sh` → `~/Library/Application Support/Code/User/prompts` (macOS)
- Cursor: `./scripts/install-cursor.sh` → `~/.cursor/skills/`
- Claude Code: `./scripts/install-claude.sh` → `~/.claude/skills/`
- Opencode: `./scripts/install-opencode.sh` → `~/.config/opencode/command/`
- All platforms at once: `./scripts/install-all.sh` runs every `install-*.sh` script in sequence

## Importing New Skills (reverse direction)
The `import-*.sh` scripts (sharing helpers from `scripts/import-lib.sh`) go the other way: they scan a platform's global config dir for skills/prompts/commands not yet tracked in this repo, copy the new item into its canonical directory, and auto-generate best-effort ports to the other three platforms (frontmatter translated, body copied as-is).
- `./scripts/import-claude.sh` ← `~/.claude/skills/`
- `./scripts/import-cursor.sh` ← `~/.cursor/skills/` (also imports `~/.cursor/rules/*.mdc` → `Cursor/rules/`, Cursor-only, no porting — rules have no established equivalent on the other three platforms yet)
- `./scripts/import-copilot.sh` ← `~/Library/Application Support/Code/User/prompts`
- `./scripts/import-opencode.sh` ← `~/.config/opencode/command/`

Auto-generated ports are a first draft only — always hand-review for tone and the platform-specific exceptions noted above, then update `README.md` and this file.

## See Also
- Full project documentation: `.github/copilot-instructions.md`
- Usage examples & architecture: `README.md`
- Opencode-specific details: `opencode/README.md`
