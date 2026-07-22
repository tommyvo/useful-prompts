#!/bin/bash

# Runs all install-*.sh scripts in this directory, one after another.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripts=()
while IFS= read -r -d '' file; do
    scripts+=("$file")
done < <(find "$SCRIPT_DIR" -maxdepth 1 -type f -name "install-*.sh" ! -name "$(basename "${BASH_SOURCE[0]}")" -print0 | sort -z)

if [ ${#scripts[@]} -eq 0 ]; then
    echo -e "${RED}No install-*.sh scripts found in $SCRIPT_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}Running ${#scripts[@]} install script(s):${NC}"
for script in "${scripts[@]}"; do
    echo "  • $(basename "$script")"
done
echo ""

for script in "${scripts[@]}"; do
    echo -e "${BLUE}==> Running $(basename "$script")${NC}"
    bash "$script"
    echo ""
done

echo -e "${GREEN}✅ All install scripts completed.${NC}"
