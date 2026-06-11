#!/bin/bash

# Cursor Commands Installer
# Installs slash commands to ~/.cursor/skills/ for global use

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CURSOR_SKILLS_DIR="$HOME/.cursor/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/Cursor/Commands"

# Check if source directory exists
if [ ! -d "$COMMANDS_DIR" ]; then
    echo -e "${RED}Error: Commands directory not found at $COMMANDS_DIR${NC}"
    exit 1
fi

# Get list of command directories
get_commands() {
    local commands=()
    while IFS= read -r -d '' dir; do
        local name=$(basename "$dir")
        if [ -f "$dir/SKILL.md" ]; then
            commands+=("$name")
        fi
    done < <(find "$COMMANDS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    printf '%s\n' "${commands[@]}"
}

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Cursor Commands Installer               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Collect commands
commands=()
while IFS= read -r cmd; do
    [ -n "$cmd" ] && commands+=("$cmd")
done < <(get_commands)

if [ ${#commands[@]} -eq 0 ]; then
    echo -e "${RED}No commands found in $COMMANDS_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  This will install the following slash commands for Cursor:${NC}"
echo ""
echo -e "${GREEN}Commands (${#commands[@]}):${NC}"
for cmd in "${commands[@]}"; do
    echo "  • /$cmd"
done
echo ""

echo -e "${BLUE}Target directory:${NC} $CURSOR_SKILLS_DIR"
echo ""

# Categorize: added, modified, unchanged
added=()
modified=()
unchanged=()

for cmd in "${commands[@]}"; do
    target="$CURSOR_SKILLS_DIR/$cmd/SKILL.md"
    source="$COMMANDS_DIR/$cmd/SKILL.md"
    if [ -f "$target" ]; then
        if cmp -s "$source" "$target"; then
            unchanged+=("$cmd")
        else
            modified+=("$cmd")
        fi
    else
        added+=("$cmd")
    fi
done

# Show what will change
if [ ${#added[@]} -gt 0 ]; then
    echo -e "${GREEN}The following commands will be ADDED:${NC}"
    for cmd in "${added[@]}"; do
        echo "  • /$cmd"
    done
    echo ""
fi

if [ ${#modified[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  The following commands will be MODIFIED / OVERWRITTEN:${NC}"
    for cmd in "${modified[@]}"; do
        echo "  • /$cmd"
    done
    echo ""
fi

if [ ${#unchanged[@]} -gt 0 ]; then
    echo -e "${BLUE}The following commands are already up-to-date (no changes):${NC}"
    for cmd in "${unchanged[@]}"; do
        echo "  • /$cmd"
    done
    echo ""
fi

# Nothing to do?
if [ ${#added[@]} -eq 0 ] && [ ${#modified[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All commands are already up-to-date. Nothing to install.${NC}"
    echo ""
    exit 0
fi

# Confirm installation (default: Yes)
echo -e "${BLUE}Do you want to proceed with the installation? [Y/n]${NC} "
read -r response

if [ -z "$response" ]; then
    response="y"
fi

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Installing commands...${NC}"
echo ""

for cmd in "${commands[@]}"; do
    target_dir="$CURSOR_SKILLS_DIR/$cmd"
    mkdir -p "$target_dir"
    cp "$COMMANDS_DIR/$cmd/SKILL.md" "$target_dir/SKILL.md"
    echo "  ✓ /$cmd"
done

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}Usage in Cursor:${NC}"
echo "  Type a slash command in the Cursor chat to invoke it:"
echo ""
echo -e "${BLUE}Examples:${NC}"
echo "  • /code-review"
echo "  • /commit-message"
echo "  • /gh-pr-code-review"
echo "  • /standup-update"
echo "  • /rails-controller-docs"
echo "  • /create-readme"
echo "  • /generate-gitignore"
echo ""
echo -e "${BLUE}Note:${NC} Restart Cursor if the commands don't appear immediately."
echo ""
