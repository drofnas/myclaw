#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSONAS_DIR="$SCRIPT_DIR/personas"

usage() {
  cat <<EOF
Usage: $(basename "$0") <target_path> <persona_name>

Deletes everything inside <target_path> (except a 'skills' subfolder),
then copies all files from the specified persona directory into it.

Arguments:
  target_path   Path to the directory to reset
  persona_name  Name of the persona (must exactly match a subdirectory of
                agents/personas/, e.g. developer, assistant, "project manager")

Available personas:
$(ls -1 "$PERSONAS_DIR" 2>/dev/null | sed 's/^/  /')
EOF
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

TARGET_PATH="$1"
PERSONA_NAME="$2"
PERSONA_DIR="$PERSONAS_DIR/$PERSONA_NAME"

if [[ ! -d "$PERSONA_DIR" ]]; then
  echo "Error: persona '$PERSONA_NAME' not found in $PERSONAS_DIR" >&2
  echo "" >&2
  usage
  exit 1
fi

if [[ ! -d "$TARGET_PATH" ]]; then
  echo "Error: target path '$TARGET_PATH' does not exist or is not a directory" >&2
  exit 1
fi

# Delete everything in target except the 'skills' folder
find "$TARGET_PATH" -mindepth 1 -maxdepth 1 ! -name 'skills' -exec rm -rf {} +
echo "Cleaned '$TARGET_PATH' (preserved 'skills/' if present)"

# Delegate the copy to change.sh
"$SCRIPT_DIR/change.sh" "$TARGET_PATH" "$PERSONA_NAME"
