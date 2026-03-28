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
