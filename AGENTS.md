# Agent Guidelines for useful-prompts

## Project Type
Reference library of AI prompts - Markdown files with YAML frontmatter. NO build/test/lint commands exist. Files deploy via shell scripts.

## Build/Test Commands
N/A - This is a content repository, not a running application. No npm/bundle/test/lint commands.

## Code Style & Conventions
- **File naming**: `kebab-case.prompt.md`, `Title Case.chatmode.md`, `kebab-case.instructions.md`
- **Frontmatter**: REQUIRED on ALL .md files with `description` + `mode`/`agent` fields
- **Dual-platform**: ALWAYS maintain BOTH versions: GitHub Copilot (`Prompt Files/`, `Chat Modes/`) AND Opencode (`opencode/command/`, `opencode/agent/`)
- **Content sync**: Strip `.prompt`/`.chatmode` from filename, change `mode: agent` → `agent: build` for Opencode versions
- **Deprecation**: Move deprecated files to `deprecated/` subfolder - NEVER delete
- **Git patterns**: Most prompts start with `git diff HEAD` to analyze changes
- **Priority emojis**: Code reviews use 🟣 CRITICAL, 🔴 HIGH, 🟡 MEDIUM, 🟢 LOW
- **Documentation**: When creating/updating prompts, update README.md table for discoverability

## Deployment & Installation
- Copilot: `./install-copilot.sh` → `~/Library/Application Support/Code/User/prompts` (macOS)
- Opencode: `./install-opencode.sh` → `~/.config/opencode/{agent,command}/`

## See Also
- Full project documentation: `.github/copilot-instructions.md` (182 lines)
- Usage examples & architecture: `README.md`
