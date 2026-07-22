#!/bin/bash

# Cursor Skills Importer
# Looks for skills in ~/.cursor/skills/ that don't exist yet in this repo,
# imports them into "Cursor/Skills/", and ports them to the other three
# platforms (Claude Code, GitHub Copilot, Opencode).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/import-lib.sh"

SOURCE_DIR="$HOME/.cursor/skills"
CURSOR_SKILLS_DIR="$SCRIPT_DIR/Cursor/Skills"
CLAUDE_SKILLS_DIR="$SCRIPT_DIR/Claude Code/Skills"
COPILOT_PROMPTS_DIR="$SCRIPT_DIR/Github Copilot/Prompt Files"
OPENCODE_COMMAND_DIR="$SCRIPT_DIR/opencode/command"

import_banner "Cursor Skills Importer"

if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: $SOURCE_DIR not found. Nothing to import.${NC}"
    exit 1
fi

# Find skill names present globally, splitting into: new (not in the repo),
# changed (in the repo but different), and unchanged (identical).
new_skills=()
changed_skills=()
unchanged_skills=()
while IFS= read -r -d '' dir; do
    name="$(basename "$dir")"
    [ -f "$dir/SKILL.md" ] || continue
    target="$CURSOR_SKILLS_DIR/$name/SKILL.md"
    if [ -f "$target" ]; then
        if cmp -s "$dir/SKILL.md" "$target"; then
            unchanged_skills+=("$name")
        else
            changed_skills+=("$name")
        fi
    elif [ -f "$CLAUDE_SKILLS_DIR/$name/SKILL.md" ] || [ -f "$COPILOT_PROMPTS_DIR/$name.prompt.md" ] || [ -f "$OPENCODE_COMMAND_DIR/$name.md" ]; then
        # Canonical Cursor copy is missing, but a ported copy already exists
        # on another platform (possibly hand-diverged) — treat as changed so
        # it isn't silently overwritten.
        changed_skills+=("$name")
    else
        new_skills+=("$name")
    fi
done < <(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ ${#unchanged_skills[@]} -gt 0 ]; then
    echo -e "${BLUE}Already tracked in this repo and unchanged:${NC}"
    for s in "${unchanged_skills[@]}"; do
        echo "  • $s"
    done
    echo ""
fi

if [ ${#new_skills[@]} -eq 0 ] && [ ${#changed_skills[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No new or changed skills found in $SOURCE_DIR. Nothing to import.${NC}"
    echo ""
    exit 0
fi

if [ ${#new_skills[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  New skills found in $SOURCE_DIR:${NC}"
    for s in "${new_skills[@]}"; do
        echo "  • $s"
    done
    echo ""
fi

if [ ${#changed_skills[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Skills already tracked but different from the global copy:${NC}"
    for s in "${changed_skills[@]}"; do
        echo "  • $s"
    done
    echo "  (you'll be asked to overwrite, skip, or abort for each of these)"
    echo ""
fi

echo -e "${BLUE}Each imported skill will be written to:${NC}"
echo "  • Cursor/Skills/<name>/SKILL.md        (canonical copy)"
echo "  • Claude Code/Skills/<name>/SKILL.md   (identical shape)"
echo "  • Github Copilot/Prompt Files/<name>.prompt.md   (generated)"
echo "  • opencode/command/<name>.md           (generated)"
echo ""

confirm_proceed || {
    echo -e "${RED}Import cancelled.${NC}"
    exit 0
}

echo ""
echo -e "${BLUE}Importing skills...${NC}"
echo ""

tmpbody="$(mktemp)"
trap 'rm -f "$tmpbody"' EXIT

import_skill() {
    local name="$1"
    local src="$SOURCE_DIR/$name/SKILL.md"
    local description
    description="$(get_frontmatter_description "$src")"
    strip_frontmatter "$src" >"$tmpbody"

    mkdir -p "$CURSOR_SKILLS_DIR/$name"
    cp "$src" "$CURSOR_SKILLS_DIR/$name/SKILL.md"

    write_skill_md "$CLAUDE_SKILLS_DIR/$name" "$name" "$description" "$tmpbody"
    write_flat_prompt "$COPILOT_PROMPTS_DIR/$name.prompt.md" "$description" "agent" "$tmpbody"
    write_flat_prompt "$OPENCODE_COMMAND_DIR/$name.md" "$description" "build" "$tmpbody"

    echo "  ✓ $name"
}

for name in "${new_skills[@]}"; do
    import_skill "$name"
done

for name in "${changed_skills[@]}"; do
    choice="$(ask_overwrite_choice "$name")"
    case "$choice" in
        skip)
            echo "  ↷ $name (skipped)"
            continue
            ;;
        abort)
            echo ""
            echo -e "${RED}Aborted. Anything already imported above was left in place.${NC}"
            exit 1
            ;;
    esac
    import_skill "$name"
done

echo ""
echo -e "${GREEN}✅ Import complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • Review the generated Copilot/Opencode files — frontmatter is templated,"
echo "    but tone or tool-specific instructions may need hand-tuning."
echo "  • Update README.md and AGENTS.md with the new skill(s)."
echo "  • Run ./install-claude.sh, ./install-copilot.sh, ./install-opencode.sh"
echo "    if you want the ported copies installed globally too."
echo ""
