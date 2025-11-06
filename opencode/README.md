# Opencode Versions

This directory contains pre-converted versions of all prompts and chat modes for use with [Opencode](https://opencode.ai/).

> [!NOTE]
> For GitHub Copilot installation, use `./install-copilot.sh` from the repository root instead. This installer is specifically for Opencode CLI users.

## Directory Structure

```text
opencode/
├── agent/      # Autonomous task execution prompts (agent: build)
└── command/    # Interactive chat mode prompts (agent: plan)
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
cp opencode/agent/code-review.md ~/.config/opencode/agent/
cp opencode/agent/commit-message.md ~/.config/opencode/agent/
cp opencode/agent/gh-pr-code-review.md ~/.config/opencode/agent/
cp opencode/agent/rails-controller-docs.md ~/.config/opencode/agent/
cp opencode/agent/create-readme.md ~/.config/opencode/agent/
```

#### Commands

Copy command prompts to your Opencode config directory:

```bash
# Install all commands
cp opencode/command/*.md ~/.config/opencode/command/

# Or install individually
cp opencode/command/beast-mode.md ~/.config/opencode/command/
cp opencode/command/principal-engineer.md ~/.config/opencode/command/
```

## Usage

### Running Agents

Agents run autonomously to complete tasks:

```bash
# Code review of uncommitted changes
opencode agent code-review

# Generate commit message
opencode agent commit-message

# Review a specific pull request (with PR number)
opencode agent gh-pr-code-review 123

# Document a Rails controller (with file path)
opencode agent rails-controller-docs app/controllers/users_controller.rb

# Create a README for the project
opencode agent create-readme
```

### Using Commands

Commands provide interactive chat modes:

```bash
# Beast Mode - autonomous problem-solving with extensive research
opencode command beast-mode "your task here"

# Principal Engineer - expert-level guidance and reviews
opencode command principal-engineer "your question here"
```

## Key Differences from GitHub Copilot

**Frontmatter:**

- GitHub Copilot uses: `mode: agent` / `mode: ask`
- Opencode uses: `agent: build` / `agent: plan`

**Arguments:**

Many Opencode agents support `{$ARGUMENTS}` for passing parameters. When you pass an argument, it gets interpolated into the prompt at runtime:

```bash
# Pass PR number as argument
opencode agent gh-pr-code-review 123
# The prompt will show: "PR Number: 123"

# Pass file path as argument
opencode agent rails-controller-docs app/controllers/api/v1/users_controller.rb
# The prompt will show: "Controller File Path: app/controllers/api/v1/users_controller.rb"
```

The agent uses this information to know what to work with.

## Available Agents

| Agent | Description | Arguments Support |
|-------|-------------|-------------------|
| `code-review` | Comprehensive code review of uncommitted changes | No |
| `commit-message` | Generate structured commit messages | No |
| `gh-pr-code-review` | Review GitHub pull requests with suggestions | Yes (PR number) |
| `rails-controller-docs` | Generate Rails controller documentation | Yes (controller path) |
| `create-readme` | Create comprehensive README files | No |

## Available Commands

| Command | Description | Mode |
|---------|-------------|------|
| `beast-mode` | Autonomous problem-solving with extensive research | build |
| `principal-engineer` | Expert engineering guidance and reviews | plan |

## More Information

For more details on using Opencode, see:

- [Opencode Documentation](https://opencode.ai/docs/)
- [Opencode Commands Guide](https://opencode.ai/docs/commands/)
- [Opencode Arguments Documentation](https://opencode.ai/docs/commands/#arguments)

## Syncing Updates

If the original GitHub Copilot prompts are updated, you can regenerate these Opencode versions by:

1. Changing `mode: agent` → `agent: build`
2. Changing `mode: ask` → `agent: plan`
3. Adding `{$ARGUMENTS}` support where applicable
4. Testing with Opencode to ensure compatibility
