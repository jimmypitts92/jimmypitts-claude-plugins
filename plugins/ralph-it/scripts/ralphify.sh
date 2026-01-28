#!/bin/bash

# Ralphify Script
# Prepares prompt input for Claude to reformat into Ralph-optimized version

set -euo pipefail

# Parse arguments
PROMPT_TEXT=""
INPUT_FILE=""
OUTPUT_FILE=""
COMPLETION_PROMISE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Ralphify - Reformat prompts for Ralph loops

USAGE:
  /ralphify "Your prompt text"
  /ralphify --file prompt.txt [--output optimized-prompt.md] [--promise TEXT]

ARGUMENTS:
  PROMPT_TEXT    Direct prompt text (if not using --file)

OPTIONS:
  --file <path>       Read prompt from file
  --output <path>     Save optimized prompt to file (default: display only)
  --promise <text>    Suggested completion promise (default: auto-generated)
  -h, --help          Show this help message

DESCRIPTION:
  Takes a simple prompt and transforms it into a structured Ralph-ready prompt
  following best practices:
  
  • Clear completion criteria
  • Incremental, numbered steps
  • Self-correction loops (run tests, fix, repeat)
  • Completion promise tags
  • Fallback behavior for when stuck
  • Proper formatting

EXAMPLES:
  # From string:
  /ralphify "Build a REST API for todos"
  
  # From file with custom promise:
  /ralphify --file rough-prompt.txt --promise "API COMPLETE"
  
  # Save to file:
  /ralphify "Fix auth bug" --output prompts/fix-auth-ralph.md

OUTPUT:
  Claude will reformat your prompt and display the improved version.
  If --output is specified, it will also be saved to that file.
HELP_EOF
      exit 0
      ;;
    --file)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --file requires a file path" >&2
        exit 1
      fi
      INPUT_FILE="$2"
      shift 2
      ;;
    --output)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --output requires a file path" >&2
        exit 1
      fi
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --promise)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --promise requires text" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      # Collect remaining as prompt text
      PROMPT_TEXT="$*"
      break
      ;;
  esac
done

# Validate input
if [[ -n "$INPUT_FILE" ]]; then
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: File not found: $INPUT_FILE" >&2
    exit 1
  fi
  if [[ ! -r "$INPUT_FILE" ]]; then
    echo "❌ Error: File not readable: $INPUT_FILE" >&2
    exit 1
  fi
  PROMPT_TEXT=$(cat "$INPUT_FILE")
fi

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "❌ Error: No prompt provided" >&2
  echo "" >&2
  echo "   Examples:" >&2
  echo "     /ralphify \"Build a REST API\"" >&2
  echo "     /ralphify --file prompt.txt" >&2
  echo "" >&2
  echo "   For help: /ralphify --help" >&2
  exit 1
fi

# Output structured data for Claude to process
cat <<EOF
📝 Ralphifying prompt...

Original prompt:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$PROMPT_TEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Output file: ${OUTPUT_FILE:-"(display only)"}
Suggested promise: ${COMPLETION_PROMISE:-"(auto-generate)"}

EOF

# Export variables for Claude to access
export RALPHIFY_ORIGINAL_PROMPT="$PROMPT_TEXT"
export RALPHIFY_OUTPUT_FILE="$OUTPUT_FILE"
export RALPHIFY_COMPLETION_PROMISE="$COMPLETION_PROMISE"

exit 0
