#!/bin/bash

# Opencode Prompts Installer
# Installs agent and command prompts to ~/.config/opencode

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENCODE_CONFIG_DIR="$HOME/.config/opencode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/opencode"

# Check if opencode directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: opencode directory not found at $SOURCE_DIR${NC}"
    exit 1
fi

# Function to check for file conflicts
check_conflicts() {
    local target_dir="$1"
    local source_dir="$2"
    local conflicts=()

    if [ -d "$target_dir" ]; then
        for file in "$source_dir"/*.md; do
            [ -f "$file" ] || continue
            local filename=$(basename "$file")
            if [ -f "$target_dir/$filename" ]; then
                conflicts+=("$filename")
            fi
        done
    fi

    echo "${conflicts[@]}"
}

# Function to list files to be installed
list_files() {
    local source_dir="$1"
    local files=()

    for file in "$source_dir"/*.md; do
        [ -f "$file" ] || continue
        files+=("$(basename "$file")")
    done

    echo "${files[@]}"
}

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Opencode Prompts Installer                  ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo ""

# Show what will be installed
echo -e "${YELLOW}⚠️  This will install the following prompts globally for Opencode:${NC}"
echo ""

# List agents
agent_files=($(list_files "$SOURCE_DIR/agent"))
if [ ${#agent_files[@]} -gt 0 ]; then
    echo -e "${GREEN}Agents (${#agent_files[@]}):${NC}"
    for file in "${agent_files[@]}"; do
        echo "  • $file"
    done
    echo ""
fi

# List commands
command_files=($(list_files "$SOURCE_DIR/command"))
if [ ${#command_files[@]} -gt 0 ]; then
    echo -e "${GREEN}Commands (${#command_files[@]}):${NC}"
    for file in "${command_files[@]}"; do
        echo "  • $file"
    done
    echo ""
fi

# Check for conflicts
echo -e "${BLUE}Target directory:${NC} $OPENCODE_CONFIG_DIR"
echo ""

agent_conflicts=($(check_conflicts "$OPENCODE_CONFIG_DIR/agent" "$SOURCE_DIR/agent"))
command_conflicts=($(check_conflicts "$OPENCODE_CONFIG_DIR/command" "$SOURCE_DIR/command"))

# Compute which files will be added (present in source but not in target)
agent_added=()
command_added=()

for file in "${agent_files[@]}"; do
    if [[ ! " ${agent_conflicts[*]} " =~ " $file " ]]; then
        agent_added+=("$file")
    fi
done

for file in "${command_files[@]}"; do
    if [[ ! " ${command_conflicts[*]} " =~ " $file " ]]; then
        command_added+=("$file")
    fi
done

# Show summary of what will change: added vs modified
if [ ${#agent_added[@]} -gt 0 ] || [ ${#command_added[@]} -gt 0 ]; then
    echo -e "${GREEN}The following files will be ADDED:${NC}"
    echo ""
    if [ ${#agent_added[@]} -gt 0 ]; then
        echo -e "${GREEN}Agents:${NC}"
        for file in "${agent_added[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
    if [ ${#command_added[@]} -gt 0 ]; then
        echo -e "${GREEN}Commands:${NC}"
        for file in "${command_added[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
fi

if [ ${#agent_conflicts[@]} -gt 0 ] || [ ${#command_conflicts[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  The following files will be MODIFIED / OVERWRITTEN:${NC}"
    echo ""

    if [ ${#agent_conflicts[@]} -gt 0 ]; then
        echo -e "${YELLOW}Agents:${NC}"
        for file in "${agent_conflicts[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi

    if [ ${#command_conflicts[@]} -gt 0 ]; then
        echo -e "${YELLOW}Commands:${NC}"
        for file in "${command_conflicts[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
fi

if [ -f "$OPENCODE_CONFIG_DIR/config" ] || [ -f "$OPENCODE_CONFIG_DIR/config.json" ]; then
    echo -e "${GREEN}✓${NC} Existing config file will NOT be modified"
    echo ""
fi

# Confirm installation (default: Yes)
echo -e "${BLUE}Do you want to proceed with the installation? [Y/n]${NC} "
read -r response

# Treat empty response as yes
if [ -z "$response" ]; then
    response="y"
fi

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Installing prompts...${NC}"
echo ""

# Create directories if they don't exist
mkdir -p "$OPENCODE_CONFIG_DIR/agent"
mkdir -p "$OPENCODE_CONFIG_DIR/command"

# Copy agents
if [ ${#agent_files[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing agents...${NC}"
    for file in "${agent_files[@]}"; do
        cp "$SOURCE_DIR/agent/$file" "$OPENCODE_CONFIG_DIR/agent/"
        echo "  ✓ $file"
    done
    echo ""
fi

# Copy commands
if [ ${#command_files[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing commands...${NC}"
    for file in "${command_files[@]}"; do
        cp "$SOURCE_DIR/command/$file" "$OPENCODE_CONFIG_DIR/command/"
        echo "  ✓ $file"
    done
    echo ""
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  opencode agent <agent-name>       # Run an agent"
echo "  opencode command <command-name>   # Start a command session"
echo ""
echo -e "${BLUE}Examples:${NC}"
echo "  opencode agent code-review"
echo "  opencode agent commit-message"
echo "  opencode command beast-mode"
echo ""
echo -e "${BLUE}For more information, visit:${NC} https://opencode.ai/"
