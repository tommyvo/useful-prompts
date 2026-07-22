## Overview

**Useful Prompts** is a comprehensive collection of reusable prompts, instructions, and custom chat modes designed to supercharge your development workflow with AI coding assistants. The same prompts are hand-ported across four platforms — **GitHub Copilot**, **Cursor**, **Claude Code**, and **Opencode** — so whichever tool you use, you get the same battle-tested workflows for commit messages, code review, documentation, and more.

### Why Use This Collection?

- **🎯 Ready-to-Use** - Drop-in prompts that work immediately across GitHub Copilot, Cursor, Claude Code, and Opencode
- **📚 Comprehensive Coverage** - From code reviews to commit messages to Rails controller documentation
- **🔧 Flexible & Extensible** - Easily customize prompts for your specific needs
- **🏗️ Best Practices Built-In** - Incorporates AI safety, prompt engineering, and responsible AI guidelines
- **🚀 Boost Productivity** - Standardize common development tasks and reduce context switching across every AI tool you use

## Getting Started

### Prerequisites

Pick whichever of these you actually use — no need to install all four:

- **VS Code** with [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension and subscription
- **[Cursor](https://cursor.com/)**
- **[Claude Code](https://claude.com/claude-code)** CLI
- **[Opencode](https://opencode.ai/)** CLI

## What's Included

This repo maintains four parallel copies of the same prompt library, one per platform:

| Directory | Platform | Format |
| --- | --- | --- |
| [`Github Copilot/`](./Github%20Copilot/) | GitHub Copilot (VS Code) | `.prompt.md`, `.instructions.md`, `.chatmode.md` |
| [`Cursor/`](./Cursor/) | Cursor | `SKILL.md` under `Cursor/Skills/<name>/` |
| [`Claude Code/`](./Claude%20Code/) | Claude Code | `SKILL.md` under `Claude Code/Skills/<name>/` |
| [`opencode/`](./opencode/) | Opencode | `.md` under `opencode/agent/` and `opencode/command/` |

Content is kept identical across all four; only the frontmatter and, occasionally, tool-specific instructions (e.g. how to fetch a PR diff) differ. See [AGENTS.md](./AGENTS.md) for the exact conversion rules.

### 📝 Prompts / Skills / Commands

Pre-built prompts for common development tasks, available on every platform:

| Prompt | Description | Copilot | Cursor | Claude Code | Opencode |
| --- | --- | --- | --- | --- | --- |
| code-review | Comprehensive local code review with security analysis | [Prompt File](<./Github Copilot/Prompt Files/code-review.prompt.md>) | [Skill](<./Cursor/Skills/code-review/SKILL.md>) | [Skill](<./Claude Code/Skills/local-code-review/SKILL.md>) | [Command](./opencode/command/code-review.md) |
| commit-message | Generate standardized commit messages for React/Rails projects | [Prompt File](<./Github Copilot/Prompt Files/commit-message.prompt.md>) | [Skill](<./Cursor/Skills/commit-message/SKILL.md>) | [Skill](<./Claude Code/Skills/commit-message/SKILL.md>) | [Command](./opencode/command/commit-message.md) |
| gh-pr-code-review | Review a GitHub PR using the `gh` CLI with unified diff suggestions | [Prompt File](<./Github Copilot/Prompt Files/gh-pr-code-review.prompt.md>) | [Skill](<./Cursor/Skills/gh-pr-code-review/SKILL.md>) | [Skill](<./Claude Code/Skills/gh-pr-code-review/SKILL.md>) | [Command](./opencode/command/gh-pr-code-review.md) |
| address-pr-comments | Find, fix, and resolve unresolved GitHub PR review comments via the `gh` CLI | [Prompt File](<./Github Copilot/Prompt Files/address-pr-comments.prompt.md>) | [Skill](<./Cursor/Skills/address-pr-comments/SKILL.md>) | [Skill](<./Claude Code/Skills/address-pr-comments/SKILL.md>) | [Command](./opencode/command/address-pr-comments.md) |
| rails-controller-docs | Generate comprehensive Rails controller documentation | [Prompt File](<./Github Copilot/Prompt Files/rails-controller-docs.prompt.md>) | [Skill](<./Cursor/Skills/rails-controller-docs/SKILL.md>) | [Skill](<./Claude Code/Skills/rails-controller-docs/SKILL.md>) | [Command](./opencode/command/rails-controller-docs.md) |
| create-readme | Create well-structured README files for projects | [Prompt File](<./Github Copilot/Prompt Files/create-readme.prompt.md>) | [Skill](<./Cursor/Skills/create-readme/SKILL.md>) | [Skill](<./Claude Code/Skills/create-readme/SKILL.md>) | [Command](./opencode/command/create-readme.md) |
| standup-update | Generate Slack standup updates from a work log markdown file | [Prompt File](<./Github Copilot/Prompt Files/standup-update.prompt.md>) | [Skill](<./Cursor/Skills/standup-update/SKILL.md>) | [Skill](<./Claude Code/Skills/standup-update/SKILL.md>) | [Command](./opencode/command/standup-update.md) |
| generate-gitignore | Generate a comprehensive `.gitignore` at the project root | [Prompt File](<./Github Copilot/Prompt Files/generate-gitignore.prompt.md>) | [Skill](<./Cursor/Skills/generate-gitignore/SKILL.md>) | [Skill](<./Claude Code/Skills/generate-gitignore/SKILL.md>) | [Command](./opencode/command/generate-gitignore.md) |

> Note: the Claude Code slash command for `code-review` is `/local-code-review` (its skill folder is named `local-code-review`) to avoid clashing with Claude Code's own review tooling; every other platform uses `code-review`.

Deprecated prompts (kept for reference, not removed) live in [`Github Copilot/Prompt Files/deprecated/`](<./Github Copilot/Prompt Files/deprecated/>).

### 🎯 Instructions (GitHub Copilot only)

> [!WARNING]
> Using instruction prompts will consume part of the AI model's context window. The more or larger instructions you have, the less room there is for your code and chat history in each Copilot request.

Language and framework-specific coding guidelines that automatically apply to relevant files:

- **[TypeScript 5 + ES2022](<./Github Copilot/Instructions/typescript-5-es2022.instructions.md>)** - Modern TypeScript development standards
- **[Ruby on Rails](<./Github Copilot/Instructions/ruby-on-rails.instructions.md>)** - Rails conventions and best practices
- **[ReactJS](<./Github Copilot/Instructions/reactjs.instructions.md>)** - React development standards with hooks and modern patterns
- **[AI Prompt Engineering](<./Github Copilot/Instructions/ai-prompt-engineering-safety-best-practices.instructions.md>)** - Comprehensive AI safety and prompt engineering guidelines

### 💬 Chat Modes / Agents

Custom personas for specialized AI assistance, available on Copilot and Opencode:

| Chat Mode | Description | Copilot | Opencode |
| --- | --- | --- | --- |
| Beast Mode 3.1 | Autonomous problem-solving with extensive research capabilities | [Chat Mode](<./Github Copilot/Chat Modes/Beast Mode 3.1.chatmode.md>) | [Agent](./opencode/agent/beast-mode.md) |
| Principal Engineer | Expert-level engineering guidance and technical leadership | [Chat Mode](<./Github Copilot/Chat Modes/Principal Engineer.chatmode.md>) | [Agent](./opencode/agent/principal-engineer.md) |

## Usage

### Using Prompt Files (GitHub Copilot)

Prompt files can be invoked directly in GitHub Copilot Chat in VS Code:

1. **Open GitHub Copilot Chat** (Ctrl/Cmd + Shift + I)
2. **Reference the prompt file** using the `/` command or by typing `@workspace` and selecting the file
3. **Provide context** as needed for your specific task

**Example:**

```
Follow instructions in create-readme.prompt.md
```

### Using Instructions (GitHub Copilot)

Instructions automatically apply to files matching their `applyTo` pattern. They provide context-aware guidance for code generation and reviews.

**Example usage in code:**
When editing TypeScript files, the TypeScript instructions automatically activate, ensuring generated code follows your project standards.

### Using Chat Modes / Agents

Activate custom chat modes to get specialized AI assistance:

- **Copilot:** Select a chat mode from the chat mode dropdown in Copilot Chat
- **Opencode:** `opencode agent beast-mode` / `opencode agent principal-engineer`

### Using Skills (Cursor / Claude Code)

Once installed (see Configuration below), invoke skills as slash commands in chat, e.g. `/code-review`, `/gh-pr-code-review`, `/address-pr-comments`.

## Examples

### Code Review Workflow

```bash
# Make some changes to your code
git add .

# Copilot:    "Follow instructions in code-review.prompt.md"
# Cursor:     /code-review
# Claude Code: /local-code-review
# Opencode:   opencode command code-review
```

The AI will:

- Analyze your uncommitted changes using `git diff HEAD`
- Generate a comprehensive review report with priority-coded suggestions
- Automatically apply appropriate fixes for security, bugs, and style issues
- Track progress with a todo list

### Commit Message Generation

```bash
# Stage your changes
git add .

# Copilot:    "Follow instructions in commit-message.prompt.md"
# Cursor / Claude Code: /commit-message
# Opencode:   opencode command commit-message
```

The AI will:

- Analyze your changes via `git diff HEAD`
- Auto-detect project type (React/Rails/Generic)
- Generate a structured commit message following conventions
- Include relevant sections (Components, API, Database, etc.)

### Pull Request Review

```bash
# Copilot:    "Follow instructions in gh-pr-code-review.prompt.md"
# Cursor / Claude Code: /gh-pr-code-review
# Opencode:   opencode command gh-pr-code-review 123
```

The AI will:

- Fetch PR details using the `gh` CLI
- Review code changes with priority-coded feedback
- Provide specific fix suggestions in unified diff format
- Include questions for the PR author and a merge recommendation

### Addressing PR Review Comments

```bash
# Cursor / Claude Code: /address-pr-comments
# Opencode:   opencode command address-pr-comments 123
```

The AI will:

- Fetch unresolved review threads via the GitHub GraphQL API
- Fix each one in-scope or draft a reply for you to approve
- Resolve fixed threads and post approved replies

## Configuration

### Installing for GitHub Copilot (VS Code)

```bash
./install-copilot.sh
```

The script will:

- Copy all chat modes from `Github Copilot/Chat Modes/` to `~/Library/Application Support/Code/User/prompts` (macOS)
- Copy all prompt files from `Github Copilot/Prompt Files/` to the same directory
- Show which files will be ADDED (new) and which will be MODIFIED/OVERWRITTEN (existing files with same name)
- The confirmation prompt defaults to Yes; pressing Enter will proceed with installation
- **Note:** Restart VS Code after installation if prompts don't appear immediately

After installation, all prompts and chat modes will be available in GitHub Copilot Chat:

- Reference prompt files: `Follow instructions in <filename>`
- Select chat modes from the chat mode dropdown menu

### Installing for Cursor

```bash
./install-cursor.sh
```

The script will:

- Copy all skills from `Cursor/Skills/` to `~/.cursor/skills/`
- Show which files will be ADDED (new) and which will be MODIFIED/OVERWRITTEN (existing)
- The confirmation prompt defaults to Yes; pressing Enter will proceed with installation
- **Note:** Restart Cursor after installation if commands don't appear immediately

Once installed, invoke them as slash commands in Cursor chat:

| Command | Description |
|---|---|
| `/code-review` | Review uncommitted local changes with prioritized suggestions |
| `/commit-message` | Draft a structured commit message (auto-detects React/Rails/Generic) |
| `/gh-pr-code-review` | Review a GitHub PR using the `gh` CLI |
| `/address-pr-comments` | Find, fix, and resolve unresolved GitHub PR review comments |
| `/rails-controller-docs` | Generate documentation for a Rails controller |
| `/create-readme` | Create a comprehensive README.md for the project |
| `/standup-update` | Generate a Slack standup update from a work log file |
| `/generate-gitignore` | Generate a comprehensive .gitignore at project root |

### Installing for Claude Code

```bash
./install-claude.sh
```

The script will:

- Copy all skills from `Claude Code/Skills/` to `~/.claude/skills/`
- Show which files will be ADDED (new) and which will be MODIFIED/OVERWRITTEN (existing)
- The confirmation prompt defaults to Yes; pressing Enter will proceed with installation
- **Note:** Restart Claude Code if skills don't appear immediately

Once installed, invoke them as slash commands in Claude Code:

| Command | Description |
|---|---|
| `/local-code-review` | Review uncommitted local changes with prioritized suggestions |
| `/commit-message` | Draft a structured commit message (auto-detects React/Rails/Generic) |
| `/gh-pr-code-review` | Review a GitHub PR using the `gh` CLI |
| `/address-pr-comments` | Find, fix, and resolve unresolved GitHub PR review comments |
| `/rails-controller-docs` | Generate documentation for a Rails controller |
| `/create-readme` | Create a comprehensive README.md for the project |
| `/standup-update` | Generate a Slack standup update from a work log file |
| `/generate-gitignore` | Generate a comprehensive .gitignore at project root |

### Using with Opencode

Pre-converted Opencode versions of all prompts and chat modes are available in the `opencode/` directory. These files use Opencode's frontmatter syntax (`agent: build` / `agent: plan`) and include support for `{$ARGUMENTS}` where applicable.

#### Quick Installation

```bash
./install-opencode.sh
```

The script will:

- Show you what will be installed (agents and commands)
- Preserve your existing Opencode config file
- Install all agents and commands to `~/.config/opencode/`
- The installer distinguishes between files that will be ADDED (new) and files that will be MODIFIED/OVERWRITTEN (existing with same name).
- The confirmation prompt defaults to Yes; pressing Enter will proceed with installation.

#### Manual Installation

**Agents** (chat-mode equivalents):

```bash
# Copy all agent prompts to Opencode config
cp opencode/agent/*.md ~/.config/opencode/agent/

# Or copy individually
cp opencode/agent/beast-mode.md ~/.config/opencode/agent/
cp opencode/agent/principal-engineer.md ~/.config/opencode/agent/
```

**Commands** (task automation, equivalent to Copilot's prompt files):

```bash
# Copy all commands to Opencode config
cp opencode/command/*.md ~/.config/opencode/command/

# Or copy individually
cp opencode/command/code-review.md ~/.config/opencode/command/
cp opencode/command/gh-pr-code-review.md ~/.config/opencode/command/
```

#### Usage in Opencode

```bash
# Run a command with no arguments
opencode command code-review

# Run a command with arguments (e.g., PR number for review)
opencode command gh-pr-code-review 123

# Use an agent mode
opencode agent beast-mode "your task here"
```

#### Key Differences from GitHub Copilot

**Frontmatter:**

- GitHub Copilot prompt files: `agent: agent` (task automation frontmatter key is `agent`, not `mode`)
- Opencode commands/agents: `agent: build` (autonomous execution) or `agent: plan` (advisory, read-only)

**Arguments:**

- Opencode commands support `{$ARGUMENTS}` for passing parameters (e.g., PR numbers, file paths). `{$ARGUMENTS}` is interpolated in the prompt at runtime.
- Example: `opencode command gh-pr-code-review 42` passes `42` as `{$ARGUMENTS}`

For more details, see the [Opencode documentation](https://opencode.ai/docs/) and [opencode/README.md](./opencode/README.md).

## Importing New Skills

If you've written a new skill/prompt/command/agent directly in one tool's global config (e.g. dropped a new `SKILL.md` in `~/.claude/skills/` or created a Copilot chat mode in VS Code) and want to bring it into this repo, use the matching import script instead of manually copying files around:

```bash
./import-claude.sh    # ~/.claude/skills/                                   -> Claude Code/Skills/
./import-cursor.sh     # ~/.cursor/skills/                                   -> Cursor/Skills/
./import-copilot.sh    # ~/Library/Application Support/Code/User/prompts    -> Github Copilot/Prompt Files/ + Chat Modes/
./import-opencode.sh   # ~/.config/opencode/{command,agent}                 -> opencode/command/ + agent/
```

Each script:

- Scans the corresponding global config directory for skills/prompts/commands/agents that don't yet exist in this repo
- Shows what's new (and what's already tracked, so you can spot local edits worth reconciling by hand) before doing anything
- Copies the new item into its canonical home directory for that platform
- Auto-generates best-effort ports to the other platforms (frontmatter translated, body copied as-is)
- The confirmation prompt defaults to Yes; pressing Enter proceeds

Chat modes / agents only port between GitHub Copilot and Opencode (Cursor and Claude Code have no chat-mode equivalent), matching the existing four-platform split described in [AGENTS.md](./AGENTS.md).

> [!NOTE]
> The generated ports are a starting point, not a final draft. Frontmatter is templated automatically, but review the new files for tone and platform-specific instructions (see AGENTS.md's notes on exceptions like `gh-pr-code-review`'s Copilot variant), then update the README tables above and run the relevant `install-*.sh` script(s).

## Best Practices

### Prompt Engineering Tips

1. **Be Specific** - Provide clear context and expected outcomes
2. **Use Examples** - Few-shot prompting improves results
3. **Iterate** - Refine prompts based on actual usage
4. **Test Safety** - Always review AI-generated code before committing

### Safety Considerations

> [!IMPORTANT]
> Review the [AI Safety Best Practices](<./Github Copilot/Instructions/ai-prompt-engineering-safety-best-practices.instructions.md>) before using prompts in production environments.

Key safety guidelines:

- Never include sensitive data (passwords, API keys, PII) in prompts
- Always review AI-generated code for security vulnerabilities
- Use appropriate moderation and validation for user-facing features
- Follow responsible AI principles and your organization's AI usage policies

## Resources

### Documentation

- **[GitHub Copilot - Prompt Files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)** - Official VS Code documentation
- **[GitHub Copilot - Custom Chat Modes](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)** - Custom chat mode guide
- **[Cursor - Commands](https://docs.cursor.com/)** - Cursor CLI/chat documentation
- **[Claude Code - Skills](https://docs.claude.com/en/docs/claude-code)** - Claude Code documentation
- **[Opencode Commands](https://opencode.ai/docs/commands/)** - Opencode CLI documentation

## Acknowledgments

- Some prompts adapted from [GitHub Awesome Copilot](https://github.com/github/awesome-copilot) community collection
- Inspired by best practices from the AI and developer communities
- Built for use with [GitHub Copilot](https://github.com/features/copilot), [Cursor](https://cursor.com/), [Claude Code](https://claude.com/claude-code), and [Opencode](https://opencode.ai/)
