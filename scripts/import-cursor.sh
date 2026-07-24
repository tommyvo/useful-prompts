#!/bin/bash

# Cursor Skills & Rules Importer
# Looks for skills in ~/.cursor/skills/ that don't exist yet in this repo,
# imports them into "Cursor/Skills/", and ports them to the other three
# platforms (Claude Code, GitHub Copilot, Opencode).
# Also looks for rules in ~/.cursor/rules/ that don't exist yet in this repo
# and imports them into "Cursor/rules/" (Cursor-only — rules have no
# established equivalent on the other three platforms yet).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/import-lib.sh"

SOURCE_DIR="$HOME/.cursor/skills"
CURSOR_SKILLS_DIR="$SCRIPT_DIR/Cursor/Skills"
CLAUDE_SKILLS_DIR="$SCRIPT_DIR/Claude Code/Skills"
COPILOT_PROMPTS_DIR="$SCRIPT_DIR/Github Copilot/Prompt Files"
OPENCODE_COMMAND_DIR="$SCRIPT_DIR/opencode/command"

RULES_SOURCE_DIR="$HOME/.cursor/rules"
CURSOR_RULES_DIR="$SCRIPT_DIR/Cursor/rules"

import_banner "Cursor Skills & Rules Importer"

# ---------------------------------------------------------------------------
# Skills
# ---------------------------------------------------------------------------

skills_new=()
skills_changed=()
skills_unchanged=()

if [ -d "$SOURCE_DIR" ]; then
    # Find skill names present globally, splitting into: new (not in the
    # repo), changed (in the repo but different), and unchanged (identical).
    while IFS= read -r -d '' dir; do
        name="$(basename "$dir")"
        [ -f "$dir/SKILL.md" ] || continue
        target="$CURSOR_SKILLS_DIR/$name/SKILL.md"
        if [ -f "$target" ]; then
            if cmp -s "$dir/SKILL.md" "$target"; then
                skills_unchanged+=("$name")
            else
                skills_changed+=("$name")
            fi
        elif [ -f "$CLAUDE_SKILLS_DIR/$name/SKILL.md" ] || [ -f "$COPILOT_PROMPTS_DIR/$name.prompt.md" ] || [ -f "$OPENCODE_COMMAND_DIR/$name.md" ]; then
            # Canonical Cursor copy is missing, but a ported copy already
            # exists on another platform (possibly hand-diverged) — treat as
            # changed so it isn't silently overwritten.
            skills_changed+=("$name")
        else
            skills_new+=("$name")
        fi
    done < <(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
else
    echo -e "${YELLOW}⚠️  $SOURCE_DIR not found. Skipping skills.${NC}"
    echo ""
fi

if [ ${#skills_unchanged[@]} -gt 0 ]; then
    echo -e "${BLUE}Skills already tracked in this repo and unchanged:${NC}"
    for s in "${skills_unchanged[@]}"; do
        echo "  • $s"
    done
    echo ""
fi

if [ ${#skills_new[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  New skills found in $SOURCE_DIR:${NC}"
    for s in "${skills_new[@]}"; do
        echo "  • $s"
    done
    echo ""
fi

if [ ${#skills_changed[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Skills already tracked but different from the global copy:${NC}"
    for s in "${skills_changed[@]}"; do
        echo "  • $s"
    done
    echo "  (you'll be asked to overwrite, skip, or abort for each of these)"
    echo ""
fi

# ---------------------------------------------------------------------------
# Rules
# ---------------------------------------------------------------------------

rules_new=()
rules_changed=()
rules_unchanged=()

if [ -d "$RULES_SOURCE_DIR" ]; then
    # Find rule files present globally, splitting into: new, changed,
    # unchanged — same logic as skills, but rules are flat *.mdc files
    # rather than a folder per name, and are Cursor-only (no porting).
    while IFS= read -r -d '' file; do
        name="$(basename "$file")"
        target="$CURSOR_RULES_DIR/$name"
        if [ -f "$target" ]; then
            if cmp -s "$file" "$target"; then
                rules_unchanged+=("$name")
            else
                rules_changed+=("$name")
            fi
        else
            rules_new+=("$name")
        fi
    done < <(find "$RULES_SOURCE_DIR" -mindepth 1 -maxdepth 1 -type f -name "*.mdc" -print0 | sort -z)
else
    echo -e "${YELLOW}⚠️  $RULES_SOURCE_DIR not found. Skipping rules.${NC}"
    echo ""
fi

if [ ${#rules_unchanged[@]} -gt 0 ]; then
    echo -e "${BLUE}Rules already tracked in this repo and unchanged:${NC}"
    for r in "${rules_unchanged[@]}"; do
        echo "  • $r"
    done
    echo ""
fi

if [ ${#rules_new[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  New rules found in $RULES_SOURCE_DIR:${NC}"
    for r in "${rules_new[@]}"; do
        echo "  • $r"
    done
    echo ""
fi

if [ ${#rules_changed[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Rules already tracked but different from the global copy:${NC}"
    for r in "${rules_changed[@]}"; do
        echo "  • $r"
    done
    echo "  (you'll be asked to overwrite, skip, or abort for each of these)"
    echo ""
fi

# ---------------------------------------------------------------------------

if [ ${#skills_new[@]} -eq 0 ] && [ ${#skills_changed[@]} -eq 0 ] && [ ${#rules_new[@]} -eq 0 ] && [ ${#rules_changed[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No new or changed skills/rules found. Nothing to import.${NC}"
    echo ""
    exit 0
fi

if [ ${#skills_new[@]} -gt 0 ] || [ ${#skills_changed[@]} -gt 0 ]; then
    echo -e "${BLUE}Each imported skill will be written to:${NC}"
    echo "  • Cursor/Skills/<name>/SKILL.md        (canonical copy)"
    echo "  • Claude Code/Skills/<name>/SKILL.md   (identical shape)"
    echo "  • Github Copilot/Prompt Files/<name>.prompt.md   (generated)"
    echo "  • opencode/command/<name>.md           (generated)"
    echo ""
fi

if [ ${#rules_new[@]} -gt 0 ] || [ ${#rules_changed[@]} -gt 0 ]; then
    echo -e "${BLUE}Each imported rule will be written to:${NC}"
    echo "  • Cursor/rules/<name>.mdc              (Cursor-only, no other platform port)"
    echo ""
fi

confirm_proceed || {
    echo -e "${RED}Import cancelled.${NC}"
    exit 0
}

echo ""
echo -e "${BLUE}Importing...${NC}"
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

import_rule() {
    local name="$1"
    mkdir -p "$CURSOR_RULES_DIR"
    cp "$RULES_SOURCE_DIR/$name" "$CURSOR_RULES_DIR/$name"
    echo "  ✓ $name"
}

for name in "${skills_new[@]}"; do
    import_skill "$name"
done

for name in "${skills_changed[@]}"; do
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

for name in "${rules_new[@]}"; do
    import_rule "$name"
done

for name in "${rules_changed[@]}"; do
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
    import_rule "$name"
done

echo ""
echo -e "${GREEN}✅ Import complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  • Review the generated Copilot/Opencode files — frontmatter is templated,"
echo "    but tone or tool-specific instructions may need hand-tuning."
echo "  • Update README.md and AGENTS.md with the new skill(s)/rule(s)."
echo "  • Run ./install-claude.sh, ./install-copilot.sh, ./install-opencode.sh"
echo "    if you want the ported copies installed globally too."
echo ""
