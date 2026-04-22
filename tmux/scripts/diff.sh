#!/usr/bin/env bash
# Open a side-by-side diff review with delta.
# Single repo: shows diff directly. Multi-repo dir: fzf picker.

set -euo pipefail

show_diff() {
    local repo="$1"
    local diff
    diff=$(git -C "$repo" diff HEAD 2>/dev/null)
    if [ -z "$diff" ]; then
        echo "No changes in $(basename "$repo")"
        read -r
        return
    fi
    echo "$diff" | delta --side-by-side --paging always
}

# Inside a git repo — diff directly
if git rev-parse --is-inside-work-tree &>/dev/null; then
    root=$(git rev-parse --show-toplevel)
    show_diff "$root"
    exit 0
fi

# Parent dir — find repos with changes
repos_with_changes=()
for d in */; do
    [ -d "$d/.git" ] || continue
    if [ -n "$(git -C "$d" status --porcelain 2>/dev/null)" ]; then
        repos_with_changes+=("${d%/}")
    fi
done

if [ ${#repos_with_changes[@]} -eq 0 ]; then
    echo "No repos with changes"
    read -r
    exit 0
fi

if [ ${#repos_with_changes[@]} -eq 1 ]; then
    show_diff "${repos_with_changes[0]}"
    exit 0
fi

selected=$(printf '%s\n' "${repos_with_changes[@]}" | fzf --prompt="diff> ")
if [ -n "$selected" ]; then
    show_diff "$selected"
fi
