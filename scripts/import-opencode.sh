#!/bin/bash

# Opencode Prompts Importer
# Looks for commands in ~/.config/opencode/ that don't exist yet in this
# repo, imports them into "opencode/command/", and ports them to the other
# three platforms (Cursor, Claude Code, GitHub Copilot).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/import-lib.sh"

OPENCODE_CONFIG_DIR="$HOME/.config/opencode"
OPENCODE_COMMAND_DIR="$REPO_ROOT/opencode/command"
CURSOR_SKILLS_DIR="$REPO_ROOT/Cursor/Skills"
CLAUDE_SKILLS_DIR="$REPO_ROOT/Claude Code/Skills"
COPILOT_PROMPTS_DIR="$REPO_ROOT/Github Copilot/Prompt Files"

import_banner "Opencode Prompts Importer"

if [ ! -d "$OPENCODE_CONFIG_DIR" ]; then
    echo -e "${RED}Error: $OPENCODE_CONFIG_DIR not found. Nothing to import.${NC}"
    exit 1
fi

# --- Commands ---
new_commands=()
changed_commands=()
unchanged_commands=()
if [ -d "$OPENCODE_CONFIG_DIR/command" ]; then
    while IFS= read -r -d '' file; do
        base="$(basename "$file")"
        name="${base%.md}"
        target="$OPENCODE_COMMAND_DIR/$base"
        if [ -f "$target" ]; then
            if cmp -s "$file" "$target"; then
                unchanged_commands+=("$name")
            else
                changed_commands+=("$name")
            fi
        elif [ -f "$CURSOR_SKILLS_DIR/$name/SKILL.md" ] || [ -f "$CLAUDE_SKILLS_DIR/$name/SKILL.md" ] || [ -f "$COPILOT_PROMPTS_DIR/$name.prompt.md" ]; then
            # Canonical Opencode command is missing, but a ported copy
            # already exists on another platform (possibly hand-diverged) —
            # treat as changed so it isn't silently overwritten.
            changed_commands+=("$name")
        else
            new_commands+=("$name")
        fi
    done < <(find "$OPENCODE_CONFIG_DIR/command" -maxdepth 1 -name "*.md" -type f -print0 | sort -z)
fi

if [ ${#unchanged_commands[@]} -gt 0 ]; then
    echo -e "${BLUE}Already tracked in this repo and unchanged:${NC}"
    for n in "${unchanged_commands[@]}"; do echo "  • $n (command)"; done
    echo ""
fi

if [ ${#new_commands[@]} -eq 0 ] && [ ${#changed_commands[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No new or changed commands found in $OPENCODE_CONFIG_DIR. Nothing to import.${NC}"
    echo ""
    exit 0
fi

if [ ${#new_commands[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  New items found in $OPENCODE_CONFIG_DIR:${NC}"
    for n in "${new_commands[@]}"; do echo "  • $n (command)"; done
    echo ""
fi

if [ ${#changed_commands[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Items already tracked but different from the global copy:${NC}"
    for n in "${changed_commands[@]}"; do echo "  • $n (command)"; done
    echo "  (you'll be asked to overwrite, skip, or abort for each of these)"
    echo ""
fi

echo -e "${BLUE}Commands will be written to:${NC}"
echo "  • opencode/command/<name>.md           (canonical copy)"
echo "  • Cursor/Skills/<name>/SKILL.md        (generated)"
echo "  • Claude Code/Skills/<name>/SKILL.md   (generated)"
echo "  • Github Copilot/Prompt Files/<name>.prompt.md   (generated)"
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

import_command() {
    local name="$1"
    local src="$OPENCODE_CONFIG_DIR/command/$name.md"
    local description
    description="$(get_frontmatter_description "$src")"
    strip_frontmatter "$src" >"$tmpbody"

    mkdir -p "$OPENCODE_COMMAND_DIR"
    cp "$src" "$OPENCODE_COMMAND_DIR/$name.md"

    write_skill_md "$CURSOR_SKILLS_DIR/$name" "$name" "$description" "$tmpbody"
    write_skill_md "$CLAUDE_SKILLS_DIR/$name" "$name" "$description" "$tmpbody"
    write_flat_prompt "$COPILOT_PROMPTS_DIR/$name.prompt.md" "$description" "agent" "$tmpbody"

    echo "  ✓ $name (command)"
}

for name in "${new_commands[@]}"; do
    import_command "$name"
done

for name in "${changed_commands[@]}"; do
    choice="$(ask_overwrite_choice "$name")"
    case "$choice" in
        skip)
            echo "  ↷ $name (command, skipped)"
            continue
            ;;
        abort)
            echo ""
            echo -e "${RED}Aborted. Anything already imported above was left in place.${NC}"
            exit 1
            ;;
    esac
    import_command "$name"
done

echo ""
echo -e "${GREEN}✅ Import complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • Review generated Cursor/Claude Code/Copilot files for tone/tool tweaks."
echo "  • Update README.md and AGENTS.md with the new item(s)."
echo "  • Run ./install-cursor.sh, ./install-claude.sh, ./install-copilot.sh"
echo "    if you want the ported copies installed globally too."
echo ""
