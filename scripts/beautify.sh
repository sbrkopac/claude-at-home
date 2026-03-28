#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

HASH=$(git rev-parse --short HEAD)
OUTFILE="/tmp/cli-beautified-${HASH}.js"

if [ -f "$OUTFILE" ]; then
  echo "$OUTFILE already exists. Delete it first to re-beautify."
  exit 1
fi

npx js-beautify cli.js -o "$OUTFILE"
echo "Created $OUTFILE ($(wc -l < "$OUTFILE") lines)"
echo "Edit $OUTFILE, then run scripts/minify.sh before committing."
