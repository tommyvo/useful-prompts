#!/bin/bash

# GitHub Copilot Prompts Importer
# Looks for prompt files and chat modes in the global VS Code Copilot
# prompts directory that don't exist yet in this repo, imports them into
# "Github Copilot/Prompt Files/" or "Github Copilot/Chat Modes/", and
# ports prompt files to the other three platforms (Cursor, Claude Code,
# Opencode). Chat modes only port to Opencode agents (Cursor/Claude Code
# don't have a chat-mode equivalent).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/import-lib.sh"

SOURCE_DIR="$HOME/Library/Application Support/Code/User/prompts"
COPILOT_PROMPTS_DIR="$SCRIPT_DIR/Github Copilot/Prompt Files"
COPILOT_CHATMODES_DIR="$SCRIPT_DIR/Github Copilot/Chat Modes"
CURSOR_SKILLS_DIR="$SCRIPT_DIR/Cursor/Skills"
CLAUDE_SKILLS_DIR="$SCRIPT_DIR/Claude Code/Skills"
OPENCODE_COMMAND_DIR="$SCRIPT_DIR/opencode/command"
OPENCODE_AGENT_DIR="$SCRIPT_DIR/opencode/agent"

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

# --- Chat modes (*.chatmode.md) ---
new_chatmodes=()
changed_chatmodes=()
unchanged_chatmodes=()
while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    name="${base%.chatmode.md}"
    target="$COPILOT_CHATMODES_DIR/$base"
    if [ -f "$target" ]; then
        if cmp -s "$file" "$target"; then
            unchanged_chatmodes+=("$name")
        else
            changed_chatmodes+=("$name")
        fi
    elif [ -f "$OPENCODE_AGENT_DIR/$(to_kebab_case "$name").md" ]; then
        # Canonical Copilot chat mode is missing, but the ported Opencode
        # agent already exists (possibly hand-diverged) — treat as changed
        # so it isn't silently overwritten.
        changed_chatmodes+=("$name")
    else
        new_chatmodes+=("$name")
    fi
done < <(find "$SOURCE_DIR" -maxdepth 1 -name "*.chatmode.md" -type f -print0 | sort -z)

if [ ${#unchanged_prompts[@]} -gt 0 ] || [ ${#unchanged_chatmodes[@]} -gt 0 ]; then
    echo -e "${BLUE}Already tracked in this repo and unchanged:${NC}"
    for n in "${unchanged_prompts[@]}"; do echo "  • $n (prompt file)"; done
    for n in "${unchanged_chatmodes[@]}"; do echo "  • $n (chat mode)"; done
    echo ""
fi

if [ ${#new_prompts[@]} -eq 0 ] && [ ${#changed_prompts[@]} -eq 0 ] && [ ${#new_chatmodes[@]} -eq 0 ] && [ ${#changed_chatmodes[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No new or changed prompt files or chat modes found in $SOURCE_DIR. Nothing to import.${NC}"
    echo ""
    exit 0
fi

if [ ${#new_prompts[@]} -gt 0 ] || [ ${#new_chatmodes[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  New items found in $SOURCE_DIR:${NC}"
    for n in "${new_prompts[@]}"; do echo "  • $n (prompt file)"; done
    for n in "${new_chatmodes[@]}"; do echo "  • $n (chat mode)"; done
    echo ""
fi

if [ ${#changed_prompts[@]} -gt 0 ] || [ ${#changed_chatmodes[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Items already tracked but different from the global copy:${NC}"
    for n in "${changed_prompts[@]}"; do echo "  • $n (prompt file)"; done
    for n in "${changed_chatmodes[@]}"; do echo "  • $n (chat mode)"; done
    echo "  (you'll be asked to overwrite, skip, or abort for each of these)"
    echo ""
fi

echo -e "${BLUE}Prompt files will be written to:${NC}"
echo "  • Github Copilot/Prompt Files/<name>.prompt.md   (canonical copy)"
echo "  • Cursor/Skills/<name>/SKILL.md        (generated)"
echo "  • Claude Code/Skills/<name>/SKILL.md   (generated)"
echo "  • opencode/command/<name>.md           (generated)"
echo ""
echo -e "${BLUE}Chat modes will be written to:${NC}"
echo "  • Github Copilot/Chat Modes/<Name>.chatmode.md   (canonical copy)"
echo "  • opencode/agent/<name>.md              (generated, no Cursor/Claude Code equivalent)"
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

import_chatmode() {
    local name="$1"
    local src="$SOURCE_DIR/$name.chatmode.md"
    local description
    description="$(get_frontmatter_description "$src")"
    strip_frontmatter "$src" >"$tmpbody"

    mkdir -p "$COPILOT_CHATMODES_DIR"
    cp "$src" "$COPILOT_CHATMODES_DIR/$name.chatmode.md"

    local kebab_name
    kebab_name="$(to_kebab_case "$name")"
    write_flat_prompt "$OPENCODE_AGENT_DIR/$kebab_name.md" "$description" "build" "$tmpbody"

    echo "  ✓ $name (chat mode)"
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

for name in "${new_chatmodes[@]}"; do
    import_chatmode "$name"
done

for name in "${changed_chatmodes[@]}"; do
    choice="$(ask_overwrite_choice "$name")"
    case "$choice" in
        skip)
            echo "  ↷ $name (chat mode, skipped)"
            continue
            ;;
        abort)
            echo ""
            echo -e "${RED}Aborted. Anything already imported above was left in place.${NC}"
            exit 1
            ;;
    esac
    import_chatmode "$name"
done

echo ""
echo -e "${GREEN}✅ Import complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • Chat modes lose their Copilot \"tools:\" list when ported — review the"
echo "    generated opencode/agent file and pick build vs plan mode by hand."
echo "  • Review generated Cursor/Claude Code/Opencode files for tone/tool tweaks."
echo "  • Update README.md and AGENTS.md with the new item(s)."
echo "  • Run ./install-cursor.sh, ./install-claude.sh, ./install-opencode.sh"
echo "    if you want the ported copies installed globally too."
echo ""
