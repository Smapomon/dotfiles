#!/bin/bash

# grepcd - Navigate to Git project directories using fzf
#
# REQUIREMENTS
#     - fzf must be installed and accessible from PATH
#     - exa (optional) for pretty previews of directories

ROOT_DIR="$HOME/dev"
SHOW_PREVIEW=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<EOF
      Usage: grepcd [OPTIONS]

      Fuzzy find Git project directories under a root path.
      Selecting a directory will print the full path to stdout,
      so it can be used for example with "cd" 'cd "\$(path/to/grepcd.sh)"'.

      Options:
        -r, --root <path>      Set the root directory to search (default: \$HOME/dev)
        -d, --detailed         Show a preview pane with directory contents
        -h, --help             Show this help message and exit

      Example:
        grepcd -d
        grepcd --root ~/code

EOF
      exit 0
      ;;
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
  preview_opts="--preview-window=up:60%"
  selected=$(printf '%s\n' "${git_dirs[@]}" | fzf --preview="$PREVIEW_CMD" $preview_opts)
else
    selected=$(printf '%s\n' "${git_dirs[@]}" | fzf)
fi

[ -n "$selected" ] && echo "$selected"
