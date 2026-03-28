# Claude at Home

Fork of Claude Code 2.0.61. Single bundled JS file distributed via Nix flakes.

## Architecture

| File | Role | Git tracked? |
|---|---|---|
| `cli.js` | Minified production bundle (~11MB, 68 lines) | Yes |
| `/tmp/cli-beautified-{hash}.js` | Pretty-printed working copy (~17MB, 447k lines), hash = HEAD commit | N/A (lives in /tmp) |

Supporting files: `flake.nix`, `package.json`, `scripts/beautify.sh`, `scripts/minify.sh`, `sdk-tools.d.ts`, `tree-sitter*.wasm`, `vendor/ripgrep`.

## Development Workflow

### The beautify-edit-minify cycle

1. **Beautify** (only if no `/tmp/cli-beautified-{hash}.js` exists for the current HEAD):
   ```
   bash scripts/beautify.sh
   ```
   Creates `/tmp/cli-beautified-{hash}.js` where `{hash}` is the short SHA of HEAD.

2. **Edit** `/tmp/cli-beautified-{hash}.js` directly. All code changes happen here.

3. **Minify** before committing:
   ```
   bash scripts/minify.sh
   ```
   Reads `/tmp/cli-beautified-{hash}.js` matching HEAD and minifies it back to `cli.js`.

4. **Commit** only `cli.js`.

### Branch switching is safe

Beautified files live in `/tmp` with the commit hash in the filename, so switching branches cannot overwrite or corrupt them. Each branch's beautified file coexists independently. Just run `bash scripts/beautify.sh` after switching to generate the new branch's copy — no cleanup needed.

## Do Not Change

These must not be modified without explicit instruction:

- **API base URLs** (`api.anthropic.com`, `console.anthropic.com`, `claude.ai`)
- **Model name strings** (`claude-sonnet-4`, `claude-opus-4`, etc.)
- **System prompt content** ("You are Claude Code, Anthropic's official CLI for Claude.")
- **Copyright and license text** in `LICENSE.md`
- **The `prepare` script** in `package.json` (blocks accidental `npm publish`)
- **`DISABLE_AUTOUPDATER`** env var set in `flake.nix`

## Nix

`flake.nix` builds a `claude-at-home` derivation that copies `cli.js`, `package.json`, `sdk-tools.d.ts`, `tree-sitter*.wasm`, and `vendor/` into the Nix store. It creates a wrapper script that invokes `node --no-warnings --enable-source-maps cli.js` with `DISABLE_AUTOUPDATER=1` set, which prevents the fork from auto-updating back to upstream Claude Code.

### Running

| Command | What it does |
|---|---|
| `nix run .` | Build and run from the repo |
| `nix run github:sbrkopac/claude-at-home` | Run from anywhere without cloning |
| `nix shell .` | Temporary shell with `claude-at-home` in PATH |
| `nix profile install .` | Persistently install to user profile |

For a permanent PATH install, add this flake as an input to your NixOS or Home Manager config.

`nix develop` does **not** put the binary in PATH — it only provides development tooling.

### Maintenance

If you add, remove, or rename files referenced in `installPhase` (the `cp` lines in `flake.nix`), the build will break. Always verify with `nix run .` after changing tracked files.

The version string is `2.0.61-athome.1` in `flake.nix` — bump the `-athome.N` suffix for local releases.

## Backporting Features

When backporting from newer Claude Code versions:

- Download reference versions to `/tmp/` and beautify there
- Variable names in the beautified source are mangled — map them carefully between versions
- Always run the full minify cycle and test manually after backporting

## Naming Convention

All new functions/variables added by us use the `athome_` prefix. This distinguishes our additions from Anthropic's mangled names, making them grep-able and avoiding collisions.

## Known Fixes

**Non-TTY stdin hang (`fd7`, line ~445959):** Upstream `fd7()` awaits stdin `end` indefinitely when `!process.stdin.isTTY`. This hangs when spawned from `child_process` (e.g. Claude Code's Bash tool) because the pipe never closes.

This is an unsolvable problem in Node.js — there is [no API to distinguish](https://github.com/nodejs/node/issues/2339) "spawned with a pipe that has no data" from "pipe with data coming soon":

- `isTTY` is `false` for both `echo foo | node app` and `child_process.exec("node app")`
- `fstatSync(0).size` returns [0 for pipes regardless of data](https://github.com/nodejs/node/issues/43669)
- `fstatSync(0).isFIFO()` is `true` for both cases
- `readableLength` is 0 until you start reading

Fix: 100ms timeout — if `-p` has a prompt and no stdin data arrives in 100ms, skip stdin. This is the standard Node.js pattern ([get-stdin uses the same approach](https://github.com/sindresorhus/get-stdin/issues/13)). The `end` listener is registered **before** the timeout to avoid race conditions with fast pipes like `echo foo | claude -p bar`. The only timeout-free alternative would be to never read stdin when `-p` has a prompt, which breaks the `echo context | claude -p "summarize"` concatenation feature.

## Per-Source Token Tracking

Tracks token usage per source (main thread vs agents) and displays it in the info bar.

### Architecture

1. **State** (`Tj9()` init, line ~1974): `DQ.sourceUsage = {}` and `DQ.agentTypeMap = new Map`
2. **Agent type recording** (`LVA()`, line ~408821): `DQ.agentTypeMap.set(F, A.agentType)` maps agent ID to type
3. **Token accumulation** (`hz0()`, line ~2048): 4th arg `Z` (source label) accumulates into `DQ.sourceUsage[Y]` where `Y = Z || "main"`
4. **Source lookup** (line ~432742): `SnA(VA, j, Y.model, DQ.agentTypeMap.get(Y.agentIdOrSessionId))` resolves agent type at token report time
5. **Display** (line ~383903): `athome_getSourceUsage()` returns `DQ.sourceUsage`, rendered in info bar

### Display modes

- **Default**: Shows "main" + aggregated "agents" rows only when agents are active
- **Detailed** (`CLAUDE_TOKEN_LOG=1`): Shows per-agent-type breakdown (Explore, Plan, etc.) plus stderr token log

### Agent spawning behavior

The LLM may proactively spawn Explore/Plan agents even for simple messages. This is driven by system prompt instructions ("use agents proactively") and is non-deterministic. The token display is accurate — these tokens are genuinely spent. The aggregated "agents" display avoids confusing users who didn't explicitly request agent usage.
