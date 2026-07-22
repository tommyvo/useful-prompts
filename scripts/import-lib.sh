#!/bin/bash

# Shared helpers for the import-*.sh scripts.
# Sourced by import-claude.sh, import-cursor.sh, import-copilot.sh, import-opencode.sh.
# Not meant to be run directly.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

import_banner() {
    local title="$1"
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    printf "${BLUE}║ %-48s ║${NC}\n" "$title"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Pull the `description:` value out of a file's YAML frontmatter.
get_frontmatter_description() {
    local file="$1"
    awk '
        NR==1 && $0=="---" { infm=1; next }
        infm==1 && $0=="---" { exit }
        infm==1 && $0 ~ /^description:/ {
            sub(/^description:[[:space:]]*/, "")
            gsub(/^"/, ""); gsub(/"$/, "")
            gsub(/^\x27/, ""); gsub(/\x27$/, "")
            print
            exit
        }
    ' "$file"
}

# Print the file's body, with the leading --- ... --- frontmatter block
# (and the single blank line that follows it) removed.
strip_frontmatter() {
    awk '
        NR==1 && $0=="---" { infm=1; next }
        infm==1 && $0=="---" { infm=0; closed=1; next }
        infm==1 { next }
        closed==1 && !printed && $0=="" { next }
        { print; printed=1 }
    ' "$1"
}

# Write a Cursor/Claude Code style SKILL.md (folder + frontmatter: name/description/disable-model-invocation).
write_skill_md() {
    local target_dir="$1" name="$2" description="$3" body_file="$4"
    mkdir -p "$target_dir"
    {
        echo "---"
        echo "name: $name"
        echo "description: $description"
        echo "disable-model-invocation: true"
        echo "---"
        echo ""
        cat "$body_file"
    } >"$target_dir/SKILL.md"
}

# Write a flat prompt/command file (Copilot prompt file or Opencode command: frontmatter description + agent).
write_flat_prompt() {
    local target_file="$1" description="$2" agent_value="$3" body_file="$4"
    mkdir -p "$(dirname "$target_file")"
    {
        echo "---"
        echo "description: \"$description\""
        echo "agent: $agent_value"
        echo "---"
        echo ""
        cat "$body_file"
    } >"$target_file"
}

to_kebab_case() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

to_title_case() {
    local input="$1" result="" part
    IFS='-' read -ra parts <<<"$input"
    for part in "${parts[@]}"; do
        result+="$(tr '[:lower:]' '[:upper:]' <<<"${part:0:1}")${part:1} "
    done
    echo "${result% }"
}

# Confirm (default: Yes). Returns 0 to proceed, 1 to cancel.
confirm_proceed() {
    echo -e "${BLUE}Do you want to proceed with the import? [Y/n]${NC} "
    read -r response
    if [ -z "$response" ]; then
        response="y"
    fi
    [[ "$response" =~ ^[Yy]$ ]]
}

# Ask how to handle an item that already exists in the repo but differs from
# the incoming global copy. Prints its choice (overwrite|skip|abort) to
# stdout; all prompt text goes to stderr so it doesn't pollute the result
# when called as choice="$(ask_overwrite_choice "$name")". No default is
# offered — the caller must pick explicitly since this can overwrite work.
ask_overwrite_choice() {
    local name="$1" answer
    while true; do
        echo -e "${YELLOW}⚠️  '$name' already exists in this repo and differs from the incoming version.${NC}" >&2
        echo -e "${BLUE}[o]verwrite / [s]kip / [a]bort?${NC} " >&2
        read -r answer
        case "$answer" in
            [Oo]*)
                echo "overwrite"
                return 0
                ;;
            [Ss]*)
                echo "skip"
                return 0
                ;;
            [Aa]*)
                echo "abort"
                return 0
                ;;
            *)
                echo -e "${RED}Please enter o, s, or a.${NC}" >&2
                ;;
        esac
    done
}
