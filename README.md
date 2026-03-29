# Claude at Home

> "Mom, can we have Claude Code?"
>
> "We have Claude Code at home."
>
> Claude Code at home:

A fork of [Claude Code](https://github.com/anthropics/claude-code) 2.0.61 with features cherry-picked from newer releases.

## Why?

Anthropic ships Claude Code updates at a breakneck pace. Each release adds more system prompt scaffolding, tool definitions, and agent infrastructure that all consume context tokens — whether you use those features or not. This fork strips it back to a leaner baseline so more of your context window goes toward your actual work.

## Features

- **Session bloat mitigation** — Caps on tool results, originalFile fields, and compaction payloads keep context lean. Bounded session maps with LRU eviction prevent unbounded memory growth.
- **Per-source token tracking** — Info bar breaks down main vs agent token usage. Set `CLAUDE_TOKEN_LOG=1` for a detailed per-agent log.
- **Cache TTL countdown + `/keep-alive`** — Status bar shows a live countdown until prompt cache expires (5 min or 1 h). `/keep-alive` toggles automatic cache refresh — when enabled, a minimal API request fires at ~30 s remaining, keeping cache reads (~0.1x cost) instead of full writes (~1.25x).
- **Lazy tool loading** — Non-essential tools load on demand via `ENABLE_TOOL_SEARCH` (`true`/`false`/`auto:N`), reducing baseline context usage.
- **Non-TTY stdin fix** — 100 ms timeout prevents the process from hanging when spawned without a TTY.

## Installation

Distributed via Nix (no npm publish):

```sh
nix run github:sbrkopac/claude-at-home
```

From a local checkout:

```sh
nix run .
```

Requires an Anthropic API key or Claude subscription.

## Based on

[Claude Code](https://github.com/anthropics/claude-code) by Anthropic.
