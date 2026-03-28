# Claude at Home

> "Mom, can we have Claude Code?"
>
> "We have Claude Code at home."
>
> Claude Code at home:

A fork of [Claude Code](https://github.com/anthropics/claude-code) 2.0.61 with features cherry-picked from newer releases.

## Why?

Anthropic ships Claude Code updates at a breakneck pace. Each release adds more system prompt scaffolding, tool definitions, and agent infrastructure that all consume context tokens — whether you use those features or not. This fork strips it back to a leaner baseline so more of your context window goes toward your actual work.

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

## Reporting Bugs

File a [GitHub issue](https://github.com/sbrkopac/claude-at-home/issues) or use the `/bug` command within the CLI. The `/bug` command also submits feedback to Anthropic's API using your credentials — telemetry localization is planned.

## Telemetry

The upstream Claude Code CLI sends analytics (Statsig), crash reports (Sentry), and performance metrics to Anthropic. This fork currently inherits that behavior.

## Based on

[Claude Code](https://github.com/anthropics/claude-code) by Anthropic.
