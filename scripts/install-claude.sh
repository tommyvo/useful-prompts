#!/bin/bash

# Claude Code Skills Installer
# Installs skills to ~/.claude/skills/ for global use

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../Claude Code/Skills"

# Check if source directory exists
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${RED}Error: Skills directory not found at $SKILLS_DIR${NC}"
    exit 1
fi

# Get list of skill directories
get_skills() {
    local skills=()
    while IFS= read -r -d '' dir; do
        local name=$(basename "$dir")
        if [ -f "$dir/SKILL.md" ]; then
            skills+=("$name")
        fi
    done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    printf '%s\n' "${skills[@]}"
}

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Skills Installer            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Collect skills
skills=()
while IFS= read -r skill; do
    [ -n "$skill" ] && skills+=("$skill")
done < <(get_skills)

if [ ${#skills[@]} -eq 0 ]; then
    echo -e "${RED}No skills found in $SKILLS_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  This will install the following skills for Claude Code:${NC}"
echo ""
echo -e "${GREEN}Skills (${#skills[@]}):${NC}"
for skill in "${skills[@]}"; do
    echo "  • /$skill"
done
echo ""

echo -e "${BLUE}Target directory:${NC} $CLAUDE_SKILLS_DIR"
echo ""

# Categorize: added, modified, unchanged
added=()
modified=()
unchanged=()

for skill in "${skills[@]}"; do
    target="$CLAUDE_SKILLS_DIR/$skill/SKILL.md"
    source="$SKILLS_DIR/$skill/SKILL.md"
    if [ -f "$target" ]; then
        if cmp -s "$source" "$target"; then
            unchanged+=("$skill")
        else
            modified+=("$skill")
        fi
    else
        added+=("$skill")
    fi
done

# Show what will change
if [ ${#added[@]} -gt 0 ]; then
    echo -e "${GREEN}The following skills will be ADDED:${NC}"
    for skill in "${added[@]}"; do
        echo "  • /$skill"
    done
    echo ""
fi

if [ ${#modified[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  The following skills will be MODIFIED / OVERWRITTEN:${NC}"
    for skill in "${modified[@]}"; do
        echo "  • /$skill"
    done
    echo ""
fi

if [ ${#unchanged[@]} -gt 0 ]; then
    echo -e "${BLUE}The following skills are already up-to-date (no changes):${NC}"
    for skill in "${unchanged[@]}"; do
        echo "  • /$skill"
    done
    echo ""
fi

# Nothing to do?
if [ ${#added[@]} -eq 0 ] && [ ${#modified[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All skills are already up-to-date. Nothing to install.${NC}"
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
echo -e "${BLUE}Installing skills...${NC}"
echo ""

for skill in "${skills[@]}"; do
    target_dir="$CLAUDE_SKILLS_DIR/$skill"
    mkdir -p "$target_dir"
    cp "$SKILLS_DIR/$skill/SKILL.md" "$target_dir/SKILL.md"
    echo "  ✓ /$skill"
done

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}Usage in Claude Code:${NC}"
echo "  Type a slash command in Claude Code to invoke it:"
echo ""
echo -e "${BLUE}Examples:${NC}"
for skill in "${skills[@]}"; do
    echo "  • /$skill"
done
echo ""
echo -e "${BLUE}Note:${NC} Restart Claude Code if the skills don't appear immediately."
echo ""
