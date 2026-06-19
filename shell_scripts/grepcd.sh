#!/bin/bash

# grepcd - Navigate to Git project directories using fzf
#
# REQUIREMENTS
#     - fzf must be installed and accessible from PATH
#     - fd must be installed and accessible from PATH
#     - eza (optional) for pretty previews of directories

ROOT_DIR="$HOME/dev"
SHOW_PREVIEW=false

die() {
    echo "Error: $*" >&2
    exit 1
}

# Parse CLI options before normalizing the root path.
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<'EOF'
Usage: grepcd [OPTIONS]

Fuzzy find Git project directories and print the selected path.

Options:
  -r, --root <path>   Search root (default: $HOME/dev)
  -d, --detailed      Show a directory preview
  -h, --help          Show this help

EOF
      exit 0
      ;;
    -r|--root)
      [[ -n "$2" && "$2" != -* ]] || die "--root requires a path argument."
      ROOT_DIR="$2"; shift 2
      ;;
    -d|--detailed)
      SHOW_PREVIEW=true
      shift
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      break
      ;;
  esac
done

# Keep the first sorted repo path and drop anything nested beneath it.
filter_nested_repos() {
    local candidate selected
    local -a selected_dirs=()

    while IFS= read -r candidate; do
        for selected in "${selected_dirs[@]}"; do
            [[ "$candidate" == "$selected"/* ]] && continue 2
        done

        selected_dirs+=("$candidate")
        printf '%s\n' "$candidate"
    done
}

# Search for .git files/dirs directly, while excluding known expensive folders.
discover_git_dirs() {
    local -a excludes=(
        -E node_modules -E .cache -E .direnv -E .terraform -E .venv
        -E .yarn -E .pnpm-store -E build -E dist -E target
    )

    fd -H --no-ignore \
        "${excludes[@]}" \
        '^\.git$' "$ROOT_DIR" -X dirname |
    LC_ALL=C sort |
    filter_nested_repos
}

command -v fzf >/dev/null 2>&1 || die "fzf is not installed."
command -v fd >/dev/null 2>&1 || die "fd is not installed."

[[ -d "$ROOT_DIR" ]] || die "root directory does not exist: $ROOT_DIR"
ROOT_DIR=$(cd "$ROOT_DIR" 2>/dev/null && pwd -P) || die "unable to access root directory: $ROOT_DIR"

# Make discovery failures explicit instead of falling through as empty results.
set -o pipefail
git_dirs=$(discover_git_dirs) || die "failed to discover Git repositories under $ROOT_DIR"
[ -n "$git_dirs" ] || die "No Git repositories found under $ROOT_DIR"

# Build preview options only when requested so normal startup stays minimal.
if [ "$SHOW_PREVIEW" = true ]; then
    if command -v eza >/dev/null 2>&1; then
        preview_cmd='eza --all --long --header --icons --git --color=always --group-directories-first {}'
    else
        preview_cmd='ls -lah {}'
    fi

    selected=$(printf '%s\n' "$git_dirs" | fzf --preview="$preview_cmd" --preview-window=up:60%)
else
    selected=$(printf '%s\n' "$git_dirs" | fzf)
fi

[ -n "$selected" ] && echo "$selected"
