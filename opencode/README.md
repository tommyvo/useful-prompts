# Opencode Versions

This directory contains pre-converted versions of all prompts and chat modes for use with [Opencode](https://opencode.ai/).

> [!NOTE]
> For GitHub Copilot installation, use `./install-copilot.sh` from the repository root instead. For Cursor, use `./install-cursor.sh`. For Claude Code, use `./install-claude.sh`. This installer is specifically for Opencode CLI users.

## Directory Structure

```text
opencode/
├── agent/      # Chat-mode equivalents (agent: build or agent: plan)
└── command/    # Task automation prompts, equivalent to Copilot's prompt files (agent: build)
```

## Installation

### Automated Installation (Recommended)

Use the provided install script from the root of this repository:

```bash
./install-opencode.sh
```

The script will:

- Show you what will be installed (agents and commands)
- Preserve your existing config file
- Copy all agents to `~/.config/opencode/agent/`
- Copy all commands to `~/.config/opencode/command/`
- The installer shows which files will be ADDED (new) and which will be MODIFIED / OVERWRITTEN (existing files with the same name).
- The confirmation prompt defaults to Yes; pressing Enter will proceed with installation.

### Manual Installation

If you prefer to install manually or selectively:

#### Agents

Copy agent prompts to your Opencode config directory:

```bash
# Install all agents
cp opencode/agent/*.md ~/.config/opencode/agent/

# Or install individually
cp opencode/agent/beast-mode.md ~/.config/opencode/agent/
cp opencode/agent/principal-engineer.md ~/.config/opencode/agent/
```

#### Commands

Copy command prompts to your Opencode config directory:

```bash
# Install all commands
cp opencode/command/*.md ~/.config/opencode/command/

# Or install individually
cp opencode/command/code-review.md ~/.config/opencode/command/
cp opencode/command/commit-message.md ~/.config/opencode/command/
cp opencode/command/gh-pr-code-review.md ~/.config/opencode/command/
cp opencode/command/address-pr-comments.md ~/.config/opencode/command/
cp opencode/command/rails-controller-docs.md ~/.config/opencode/command/
cp opencode/command/create-readme.md ~/.config/opencode/command/
cp opencode/command/standup-update.md ~/.config/opencode/command/
cp opencode/command/generate-gitignore.md ~/.config/opencode/command/
```

## Usage

### Running Commands

Commands run autonomously to complete tasks:

```bash
# Code review of uncommitted changes
opencode command code-review

# Generate commit message
opencode command commit-message

# Review a specific pull request (with PR number)
opencode command gh-pr-code-review 123

# Address unresolved review comments on a pull request
opencode command address-pr-comments 123

# Document a Rails controller (with file path)
opencode command rails-controller-docs app/controllers/users_controller.rb

# Create a README for the project
opencode command create-readme

# Generate a Slack standup update from a work log file
opencode command standup-update

# Generate a comprehensive .gitignore
opencode command generate-gitignore
```

### Using Agents

Agents provide chat-mode-style personas:

```bash
# Beast Mode - autonomous problem-solving with extensive research
opencode agent beast-mode "your task here"

# Principal Engineer - expert-level guidance and reviews
opencode agent principal-engineer "your question here"
```

## Key Differences from GitHub Copilot

**Frontmatter:**

- GitHub Copilot prompt files use: `agent: agent`
- Opencode uses: `agent: build` (autonomous execution) or `agent: plan` (advisory/read-only)

**Arguments:**

Many Opencode commands support `{$ARGUMENTS}` for passing parameters. When you pass an argument, it gets interpolated into the prompt at runtime:

```bash
# Pass PR number as argument
opencode command gh-pr-code-review 123
# The prompt will show: "PR Number: 123"

# Pass file path as argument
opencode command rails-controller-docs app/controllers/api/v1/users_controller.rb
# The prompt will show: "Controller File Path: app/controllers/api/v1/users_controller.rb"
```

The command uses this information to know what to work with.

## Available Commands

| Command | Description | Arguments Support |
|-------|-------------|-------------------|
| `code-review` | Comprehensive code review of uncommitted changes | No |
| `commit-message` | Generate structured commit messages (auto-detects React/Rails/Generic) | No |
| `gh-pr-code-review` | Review GitHub pull requests with unified diff suggestions | Yes (PR number/URL) |
| `address-pr-comments` | Find, fix, and resolve unresolved GitHub PR review comments | Yes (PR number/URL) |
| `rails-controller-docs` | Generate Rails controller documentation | Yes (controller path) |
| `create-readme` | Create comprehensive README files | No |
| `standup-update` | Generate a Slack standup update from a work log markdown file | No |
| `generate-gitignore` | Generate a comprehensive .gitignore at project root | No |

## Available Agents

| Agent | Description | Mode |
|---------|-------------|------|
| `beast-mode` | Autonomous problem-solving with extensive research | build |
| `principal-engineer` | Expert engineering guidance and reviews | plan |

## More Information

For more details on using Opencode, see:

- [Opencode Documentation](https://opencode.ai/docs/)
- [Opencode Commands Guide](https://opencode.ai/docs/commands/)
- [Opencode Arguments Documentation](https://opencode.ai/docs/commands/#arguments)

## Syncing Updates

If the original prompts are updated (in `Github Copilot/`, `Cursor/`, or `Claude Code/`), regenerate these Opencode versions by:

1. Changing `agent: agent` (Copilot) → `agent: build` (or `agent: plan` for advisory/read-only modes)
2. Adding `{$ARGUMENTS}` support where the prompt takes a natural argument (PR number, file path, etc.)
3. Keeping the body content identical apart from frontmatter and argument wiring
4. Testing with Opencode to ensure compatibility
