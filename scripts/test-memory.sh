#!/usr/bin/env bash
# scripts/test-memory.sh - Measure session bloat and memory metrics
set -euo pipefail
PROJECT_DIR="$HOME/.claude/projects/-home-nixos-mvp-claude-code-fork"
echo "=== Session File Metrics ==="
echo "Session directory: $PROJECT_DIR"
ls -lhS "$PROJECT_DIR"/*.jsonl 2>/dev/null | head -10 || echo "No sessions"
echo ""
echo "=== Per-file line counts and sizes ==="
for f in "$PROJECT_DIR"/*.jsonl; do
  [ -f "$f" ] || continue
  lines=$(wc -l < "$f")
  size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
  biggest_line=$(awk '{ print length }' "$f" | sort -rn | head -1)
  echo "$(basename "$f"): ${lines} lines, $(numfmt --to=iec $size), biggest line: ${biggest_line} chars"
done
echo ""
echo "=== toolUseResult field sizes in latest session ==="
latest=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | head -1)
if [ -n "$latest" ]; then
  node -e "
    const lines = require('fs').readFileSync('$latest','utf8').split('\n').filter(Boolean);
    let count=0, totalBytes=0, maxBytes=0, maxField='';
    for (const line of lines) {
      try {
        const obj = JSON.parse(line);
        if (obj.toolUseResult) {
          const s = JSON.stringify(obj.toolUseResult);
          count++;
          totalBytes += s.length;
          if (s.length > maxBytes) { maxBytes = s.length; maxField = Object.keys(obj.toolUseResult).join(','); }
        }
      } catch {}
    }
    console.log('  Entries with toolUseResult:', count);
    console.log('  Total toolUseResult bytes:', (totalBytes/1024/1024).toFixed(2), 'MB');
    console.log('  Largest single toolUseResult:', (maxBytes/1024).toFixed(1), 'KB, fields:', maxField);
  "
fi
