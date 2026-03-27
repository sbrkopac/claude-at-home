#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f cli-beautified.js ]; then
  echo "cli-beautified.js already exists. Delete it first to re-beautify."
  exit 1
fi

npx terser cli.js --module --no-rename --beautify -o cli-beautified.js
echo "Created cli-beautified.js ($(wc -l < cli-beautified.js) lines)"
echo "Edit cli-beautified.js, then run scripts/minify.sh before committing."
