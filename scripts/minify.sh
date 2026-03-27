#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f cli-beautified.js ]; then
  echo "cli-beautified.js not found. Run scripts/beautify.sh first."
  exit 1
fi

npx terser cli-beautified.js --module --no-rename -o cli.js
node --check cli.js
echo "Minified cli-beautified.js -> cli.js ($(wc -l < cli.js) lines, $(wc -c < cli.js) bytes)"
echo "cli.js is ready to commit."
