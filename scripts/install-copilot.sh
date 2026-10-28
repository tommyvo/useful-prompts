#!/bin/bash

# GitHub Copilot Prompts Installer
# Installs prompt files to ~/Library/Application Support/Code/User/prompts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COPILOT_PROMPTS_DIR="$HOME/Library/Application Support/Code/User/prompts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILES_DIR="$SCRIPT_DIR/../Github Copilot/Prompt Files"

# Check if source directories exist
if [ ! -d "$PROMPT_FILES_DIR" ]; then
    echo -e "${RED}Error: Prompt Files directory not found at $PROMPT_FILES_DIR${NC}"
    exit 1
fi

# Function to check for file conflicts (files that exist and have different content)
check_conflicts() {
    local target_dir="$1"
    local source_dir="$2"
    local conflicts=()

    if [ -d "$target_dir" ]; then
        while IFS= read -r -d '' file; do
            local filename=$(basename "$file")
            if [ -f "$target_dir/$filename" ]; then
                # Check if files differ
                if ! cmp -s "$file" "$target_dir/$filename"; then
                    conflicts+=("$filename")
                fi
            fi
        done < <(find "$source_dir" -maxdepth 1 -name "*.md" -type f -print0)
    fi

    printf '%s\n' "${conflicts[@]}"
}

# Function to list files to be installed
list_files() {
    local source_dir="$1"
    local files=()

    while IFS= read -r -d '' file; do
        files+=("$(basename "$file")")
    done < <(find "$source_dir" -maxdepth 1 -name "*.md" -type f -print0)

    printf '%s\n' "${files[@]}"
}

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GitHub Copilot Prompts Installer            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Show what will be installed
echo -e "${YELLOW}⚠️  This will install the following prompts for GitHub Copilot in VS Code:${NC}"
echo ""

# List prompt files
prompt_files=()
while IFS= read -r file; do
    [ -n "$file" ] && prompt_files+=("$file")
done < <(list_files "$PROMPT_FILES_DIR")

if [ ${#prompt_files[@]} -gt 0 ]; then
    echo -e "${GREEN}Prompt Files (${#prompt_files[@]}):${NC}"
    for file in "${prompt_files[@]}"; do
        echo "  • $file"
    done
    echo ""
fi

# Check for conflicts
echo -e "${BLUE}Target directory:${NC} $COPILOT_PROMPTS_DIR"
echo ""

prompt_conflicts=()
while IFS= read -r file; do
    [ -n "$file" ] && prompt_conflicts+=("$file")
done < <(check_conflicts "$COPILOT_PROMPTS_DIR" "$PROMPT_FILES_DIR")

# Compute which files will be added (new files) and which are unchanged (identical)
prompt_added=()
prompt_unchanged=()

for file in "${prompt_files[@]}"; do
    if [ -f "$COPILOT_PROMPTS_DIR/$file" ]; then
        # File exists - check if it's in conflicts (different) or unchanged (identical)
        found_conflict=false
        for conflict in "${prompt_conflicts[@]}"; do
            if [ "$file" = "$conflict" ]; then
                found_conflict=true
                break
            fi
        done
        if [ "$found_conflict" = false ]; then
            prompt_unchanged+=("$file")
        fi
    else
        # File doesn't exist - it will be added
        prompt_added+=("$file")
    fi
done

# Show summary of what will change: added vs modified
if [ ${#prompt_added[@]} -gt 0 ]; then
    echo -e "${GREEN}The following files will be ADDED:${NC}"
    echo ""
    if [ ${#prompt_added[@]} -gt 0 ]; then
        echo -e "${GREEN}Prompt Files:${NC}"
        for file in "${prompt_added[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
fi

if [ ${#prompt_conflicts[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  The following files will be MODIFIED / OVERWRITTEN:${NC}"
    echo ""


    if [ ${#prompt_conflicts[@]} -gt 0 ]; then
        echo -e "${YELLOW}Prompt Files:${NC}"
        for file in "${prompt_conflicts[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
fi

if [ ${#prompt_unchanged[@]} -gt 0 ]; then
    echo -e "${BLUE}The following files are already up-to-date (no changes):${NC}"
    echo ""
    if [ ${#prompt_unchanged[@]} -gt 0 ]; then
        echo -e "${BLUE}Prompt Files:${NC}"
        for file in "${prompt_unchanged[@]}"; do
            echo "  • $file"
        done
        echo ""
    fi
fi

# Check if there are any changes to install
if [ ${#prompt_added[@]} -eq 0 ] && [ ${#prompt_conflicts[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All files are already up-to-date. Nothing to install.${NC}"
    echo ""
    exit 0
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

# Create directory if it doesn't exist
mkdir -p "$COPILOT_PROMPTS_DIR"

# Copy prompt files
if [ ${#prompt_files[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing prompt files...${NC}"
    for file in "${prompt_files[@]}"; do
        cp "$PROMPT_FILES_DIR/$file" "$COPILOT_PROMPTS_DIR/"
        echo "  ✓ $file"
    done
    echo ""
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}Usage in VS Code:${NC}"
echo "  1. Open GitHub Copilot Chat (Cmd+Shift+I)"
echo "  2. Reference a prompt file: 'Follow instructions in <filename>'"
echo ""
echo -e "${BLUE}Examples:${NC}"
echo "  • 'Follow instructions in local-code-review.prompt.md'"
echo "  • 'Follow instructions in commit-message.prompt.md'"
echo ""
echo -e "${BLUE}Note:${NC} Restart VS Code if the prompts don't appear immediately."
echo ""
