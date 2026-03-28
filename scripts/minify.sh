#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

HASH=$(git rev-parse --short HEAD)
EXPECTED="/tmp/cli-beautified-${HASH}.js"

if [ ! -f "$EXPECTED" ]; then
  echo "$EXPECTED not found. Run scripts/beautify.sh first."
  exit 1
fi

npx terser "$EXPECTED" --module --no-rename -o cli.js
node --check cli.js
echo "Minified $EXPECTED -> cli.js ($(wc -l < cli.js) lines, $(wc -c < cli.js) bytes)"
echo "cli.js is ready to commit."
