#!/bin/bash

# GitHub Copilot Prompts Importer
# Looks for prompt files in the global VS Code Copilot prompts directory
# that don't exist yet in this repo, imports them into
# "Github Copilot/Prompt Files/", and ports them to the other three
# platforms (Cursor, Claude Code, Opencode).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/import-lib.sh"

SOURCE_DIR="$HOME/Library/Application Support/Code/User/prompts"
COPILOT_PROMPTS_DIR="$REPO_ROOT/Github Copilot/Prompt Files"
CURSOR_SKILLS_DIR="$REPO_ROOT/Cursor/Skills"
CLAUDE_SKILLS_DIR="$REPO_ROOT/Claude Code/Skills"
OPENCODE_COMMAND_DIR="$REPO_ROOT/opencode/command"

import_banner "GitHub Copilot Prompts Importer"

if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: $SOURCE_DIR not found. Nothing to import.${NC}"
    exit 1
fi

# --- Prompt files (*.prompt.md) ---
new_prompts=()
changed_prompts=()
unchanged_prompts=()
while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    name="${base%.prompt.md}"
    target="$COPILOT_PROMPTS_DIR/$base"
    if [ -f "$target" ]; then
        if cmp -s "$file" "$target"; then
            unchanged_prompts+=("$name")
        else
            changed_prompts+=("$name")
        fi
    elif [ -f "$CURSOR_SKILLS_DIR/$name/SKILL.md" ] || [ -f "$CLAUDE_SKILLS_DIR/$name/SKILL.md" ] || [ -f "$OPENCODE_COMMAND_DIR/$name.md" ]; then
        # Canonical Copilot prompt file is missing, but a ported copy
        # already exists on another platform (possibly hand-diverged) —
        # treat as changed so it isn't silently overwritten.
        changed_prompts+=("$name")
    else
        new_prompts+=("$name")
    fi
done < <(find "$SOURCE_DIR" -maxdepth 1 -name "*.prompt.md" -type f -print0 | sort -z)

if [ ${#unchanged_prompts[@]} -gt 0 ]; then
    echo -e "${BLUE}Already tracked in this repo and unchanged:${NC}"
    for n in "${unchanged_prompts[@]}"; do echo "  • $n (prompt file)"; done
    echo ""
fi

if [ ${#new_prompts[@]} -eq 0 ] && [ ${#changed_prompts[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No new or changed prompt files found in $SOURCE_DIR. Nothing to import.${NC}"
    echo ""
    exit 0
fi

if [ ${#new_prompts[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  New items found in $SOURCE_DIR:${NC}"
    for n in "${new_prompts[@]}"; do echo "  • $n (prompt file)"; done
    echo ""
fi

if [ ${#changed_prompts[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Items already tracked but different from the global copy:${NC}"
    for n in "${changed_prompts[@]}"; do echo "  • $n (prompt file)"; done
    echo "  (you'll be asked to overwrite, skip, or abort for each of these)"
    echo ""
fi

echo -e "${BLUE}Prompt files will be written to:${NC}"
echo "  • Github Copilot/Prompt Files/<name>.prompt.md   (canonical copy)"
echo "  • Cursor/Skills/<name>/SKILL.md        (generated)"
echo "  • Claude Code/Skills/<name>/SKILL.md   (generated)"
echo "  • opencode/command/<name>.md           (generated)"
echo ""
confirm_proceed || {
    echo -e "${RED}Import cancelled.${NC}"
    exit 0
}

echo ""
echo -e "${BLUE}Importing...${NC}"
echo ""

tmpbody="$(mktemp)"
trap 'rm -f "$tmpbody"' EXIT

import_prompt() {
    local name="$1"
    local src="$SOURCE_DIR/$name.prompt.md"
    local description
    description="$(get_frontmatter_description "$src")"
    strip_frontmatter "$src" >"$tmpbody"

    mkdir -p "$COPILOT_PROMPTS_DIR"
    cp "$src" "$COPILOT_PROMPTS_DIR/$name.prompt.md"

    write_skill_md "$CURSOR_SKILLS_DIR/$name" "$name" "$description" "$tmpbody"
    write_skill_md "$CLAUDE_SKILLS_DIR/$name" "$name" "$description" "$tmpbody"
    write_flat_prompt "$OPENCODE_COMMAND_DIR/$name.md" "$description" "build" "$tmpbody"

    echo "  ✓ $name (prompt file)"
}

for name in "${new_prompts[@]}"; do
    import_prompt "$name"
done

for name in "${changed_prompts[@]}"; do
    choice="$(ask_overwrite_choice "$name")"
    case "$choice" in
        skip)
            echo "  ↷ $name (prompt file, skipped)"
            continue
            ;;
        abort)
            echo ""
            echo -e "${RED}Aborted. Anything already imported above was left in place.${NC}"
            exit 1
            ;;
    esac
    import_prompt "$name"
done

echo ""
echo -e "${GREEN}✅ Import complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • Review generated Cursor/Claude Code/Opencode files for tone/tool tweaks."
echo "  • Update README.md and AGENTS.md with the new item(s)."
echo "  • Run ./install-cursor.sh, ./install-claude.sh, ./install-opencode.sh"
echo "    if you want the ported copies installed globally too."
echo ""
