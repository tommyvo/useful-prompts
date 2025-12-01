## Overview

**Useful Prompts** is a comprehensive collection of reusable prompt files, instructions, and custom chat modes designed to supercharge your development workflow with AI coding assistants like GitHub Copilot. Whether you're writing commit messages, reviewing code, generating documentation, or configuring development environments, this repository provides battle-tested prompts that help you get the most out of AI-assisted development.

### Why Use This Collection?

- **🎯 Ready-to-Use** - Drop-in prompts that work immediately with GitHub Copilot in VS Code
- **📚 Comprehensive Coverage** - From code reviews to commit messages to Rails controller documentation
- **🔧 Flexible & Extensible** - Easily customize prompts for your specific needs
- **🏗️ Best Practices Built-In** - Incorporates AI safety, prompt engineering, and responsible AI guidelines
- **🚀 Boost Productivity** - Standardize common development tasks and reduce context switching

## Getting Started

### Prerequisites

- **VS Code** with [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension installed
- **GitHub Copilot subscription** (individual, business, or enterprise)
- Basic familiarity with AI coding assistants

> [!TIP]
> These prompts also work with [Opencode](https://opencode.ai/), though you may need to adjust the frontmatter metadata.

## What's Included

### 📝 Prompt Files

Pre-built prompts for common development tasks. See the [Prompt Files README](./Prompt%20Files/README.md) for detailed usage instructions.

| Prompt                                                                              | Description                                                    | Mode  |
| ----------------------------------------------------------------------------------- | -------------------------------------------------------------- | ----- |
| [code-review.prompt.md](./Prompt%20Files/code-review.prompt.md)                     | Comprehensive local code review with security analysis         | Prompt File |
| [commit-message.prompt.md](./Prompt%20Files/commit-message.prompt.md)               | Generate standardized commit messages for React/Rails projects | Prompt File |
| [gh-pr-code-review.prompt.md](./Prompt%20Files/gh-pr-code-review.prompt.md)         | Review GitHub pull requests with unified diff suggestions      | Prompt File |
| [rails-controller-docs.prompt.md](./Prompt%20Files/rails-controller-docs.prompt.md) | Generate comprehensive Rails controller documentation          | Prompt File |
| [create-readme.prompt.md](./Prompt%20Files/create-readme.prompt.md)                 | Create well-structured README files for projects               | Prompt File |
| [standup-update.prompt.md](./Prompt%20Files/standup-update.prompt.md)               | Generate Slack standup updates from work log markdown files    | Prompt File |

### 🎯 Instructions

> [!WARNING] > **Using instruction prompts will consume part of the AI model's context window.** The more or larger instructions you have, the less room there is for your code and chat history in each Copilot request.

Language and framework-specific coding guidelines that automatically apply to relevant files.

- **[TypeScript 5 + ES2022](./Instructions/typescript-5-es2022.instructions.md)** - Modern TypeScript development standards
- **[Ruby on Rails](./Instructions/ruby-on-rails.instructions.md)** - Rails conventions and best practices
- **[ReactJS](./Instructions/reactjs.instructions.md)** - React development standards with hooks and modern patterns
- **[AI Prompt Engineering](./Instructions/ai-prompt-engineering-safety-best-practices.instructions.md)** - Comprehensive AI safety and prompt engineering guidelines

### 💬 Chat Modes

Custom chat mode configurations for specialized AI assistance. See the [Chat Modes README](./Chat%20Modes/README.md) for more details.

- **[Beast Mode 3.1](./Chat%20Modes/gh-copilot-beast-mode-3.1.chatmode.md)** - Autonomous problem-solving with extensive research capabilities
- **[Principal Engineer](./Chat%20Modes/Principal%20Engineer.chatmode.md)** - Expert-level engineering guidance and technical leadership

## Usage

### Using Prompt Files

Prompt files can be invoked directly in GitHub Copilot Chat in VS Code:

1. **Open GitHub Copilot Chat** (Ctrl/Cmd + Shift + I)
2. **Reference the prompt file** using the `/` command or by typing `@workspace` and selecting the file
3. **Provide context** as needed for your specific task

**Example:**

```
Follow instructions in create-readme.prompt.md
```

### Using Instructions

Instructions automatically apply to files matching their `applyTo` pattern. They provide context-aware guidance for code generation and reviews.

**Example usage in code:**
When editing TypeScript files, the TypeScript instructions automatically activate, ensuring generated code follows your project standards.

### Using Chat Modes

Activate custom chat modes to get specialized AI assistance:

1. **Select a chat mode** from the chat mode dropdown in Copilot Chat
2. **Interact naturally** - the AI will follow the mode's specialized behavior
3. **Leverage mode-specific features** like autonomous problem-solving or principal-level code reviews

## Examples

### Code Review Workflow

```bash
# Make some changes to your code
git add .

# In Copilot Chat, run:
# "Follow instructions in code-review.prompt.md"
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

# In Copilot Chat:
# "Follow instructions in commit-message.prompt.md"
```

The AI will:

- Analyze your changes via `git diff HEAD`
- Auto-detect project type (React/Rails/Generic)
- Generate a structured commit message following conventions
- Include relevant sections (Components, API, Database, etc.)

### Pull Request Review

```bash
# In Copilot Chat with a PR open:
# "Follow instructions in gh-pr-code-review.prompt.md"
```

The AI will:

- Fetch PR details using the `gh` CLI
- Review code changes with priority-coded feedback
- Provide specific fix suggestions in unified diff format
- Include questions for the PR author and a merge recommendation

## Configuration

### Installing for GitHub Copilot

To make all prompts and chat modes available globally in VS Code, use the automated installer:

```bash
./install-copilot.sh
```

The script will:

- Copy all chat modes from `Chat Modes/` to `~/Library/Application Support/Code/User/prompts` (macOS)
- Copy all prompt files from `Prompt Files/` to the same directory
- Show which files will be ADDED (new) and which will be MODIFIED/OVERWRITTEN (existing files with same name)
- The confirmation prompt defaults to Yes; pressing Enter will proceed with installation
- **Note:** Restart VS Code after installation if prompts don't appear immediately

After installation, all prompts and chat modes will be available in GitHub Copilot Chat:

- Reference prompt files: `Follow instructions in <filename>`
- Select chat modes from the chat mode dropdown menu

### Using with Opencode

Pre-converted Opencode versions of all prompts and chat modes are available in the `opencode/` directory. These files use Opencode's frontmatter syntax (`agent: build` / `agent: plan`) and include support for `{$ARGUMENTS}` where applicable.

#### Quick Installation

Use the automated install script to install all Opencode prompts:

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

**Agents** (autonomous task execution):

```bash
# Copy all agent prompts to Opencode config
cp opencode/agent/*.md ~/.config/opencode/agent/

# Or copy individual agents
cp opencode/agent/code-review.md ~/.config/opencode/agent/
cp opencode/agent/commit-message.md ~/.config/opencode/agent/
```

**Commands** (interactive chat modes):

```bash
# Copy all commands to Opencode config
cp opencode/command/*.md ~/.config/opencode/command/

# Or copy individual commands
cp opencode/command/beast-mode.md ~/.config/opencode/command/
cp opencode/command/principal-engineer.md ~/.config/opencode/command/
```

#### Usage in Opencode

Once installed, use them like this:

```bash
# Run an agent with no arguments
opencode agent code-review

# Run an agent with arguments (e.g., PR number for review)
opencode agent gh-pr-code-review 123

# Use a command mode
opencode command beast-mode "your task here"
```

#### Key Differences from GitHub Copilot

**Frontmatter:**

- GitHub Copilot: `mode: agent` / `mode: ask`
- Opencode: `agent: build` / `agent: plan`

**Arguments:**

- Opencode agents support `{$ARGUMENTS}` for passing parameters (e.g., PR numbers, file paths). `{$ARGUMENTS}` will be interpolated in the prompt at runtime.
- Example: `opencode agent gh-pr-code-review 42` passes `42` as `{$ARGUMENTS}`

For more details, see the [Opencode documentation](https://opencode.ai/docs/).

## Best Practices

### Prompt Engineering Tips

1. **Be Specific** - Provide clear context and expected outcomes
2. **Use Examples** - Few-shot prompting improves results
3. **Iterate** - Refine prompts based on actual usage
4. **Test Safety** - Always review AI-generated code before committing

### Safety Considerations

> [!IMPORTANT]
> Review the [AI Safety Best Practices](./Instructions/ai-prompt-engineering-safety-best-practices.instructions.md) before using prompts in production environments.

Key safety guidelines:

- Never include sensitive data (passwords, API keys, PII) in prompts
- Always review AI-generated code for security vulnerabilities
- Use appropriate moderation and validation for user-facing features
- Follow responsible AI principles and your organization's AI usage policies

## Resources

### Documentation

- **[GitHub Copilot - Prompt Files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)** - Official VS Code documentation
- **[GitHub Copilot - Custom Chat Modes](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)** - Custom chat mode guide
- **[Opencode Commands](https://opencode.ai/docs/commands/)** - Opencode CLI documentation

## Acknowledgments

- Some prompts adapted from [GitHub Awesome Copilot](https://github.com/github/awesome-copilot) community collection
- Inspired by best practices from the AI and developer communities
- Built for use with [GitHub Copilot](https://github.com/features/copilot) and [VS Code](https://code.visualstudio.com)
