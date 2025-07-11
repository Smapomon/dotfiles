#!/bin/bash

# grepcd - Navigate to Git project directories using fzf
#
# REQUIREMENTS
#     - fzf must be installed and accessible from PATH
#     - exa (optional) for pretty previews of directories
#
# OPTIONS
#     -r, --root <path>
#         Specify the root directory to search under (default: $HOME/dev)
#
#     -d, --detailed
#         Enable a preview window showing contents of each directory
#
# EXAMPLES
#     grepcd                     # Search in default root ($HOME/dev)
#     grepcd -r ~/projects       # Search in a custom root directory
#     grepcd -d                  # Enable preview when selecting
#     grepcd -r ~/code -d        # Custom root + preview

ROOT_DIR="$HOME/dev"
SHOW_PREVIEW=false
echo "Root directory set to $ROOT_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--root)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "Error: --root requires a path argument." >&2
        exit 1
      fi
      ROOT_DIR="$2"
      shift 2
      ;;
    -d|--detailed)
      SHOW_PREVIEW=true
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    exit 1
fi

mapfile -t git_dirs < <(find "$ROOT_DIR" -type d -name .git -prune -exec dirname {} \; | sort)

if [ ${#git_dirs[@]} -eq 0 ]; then
    echo "No Git repositories found under $ROOT_DIR" >&2
    exit 1
fi

PREVIEW_CMD=$(command -v exa >/dev/null 2>&1 \
    && echo 'exa --long --header --icons --color=always --group-directories-first {}' \
    || echo 'ls -lah {}')

if [ "$SHOW_PREVIEW" = true ]; then
    selected=$(printf '%s\n' "${git_dirs[@]}" | fzf --preview="$PREVIEW_CMD" --preview-window=right:60%)
else
    selected=$(printf '%s\n' "${git_dirs[@]}" | fzf)
fi

[ -n "$selected" ] && echo "$selected"
