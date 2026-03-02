#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSONAS_DIR="$SCRIPT_DIR/personas"

usage() {
  cat <<EOF
Usage: $(basename "$0") <target_path> <persona_name>

Copies all files from the specified persona directory into <target_path>,
overwriting any files with the same name.

Arguments:
  target_path   Path to the directory where persona files will be copied
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

cp -r "$PERSONA_DIR/." "$TARGET_PATH/"
echo "Copied persona '$PERSONA_NAME' into '$TARGET_PATH'"
