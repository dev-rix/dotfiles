# Dotfiles Audit Skip List

Files and directories decided against tracking, with reasoning. The `dotfiles-audit` skill filters these out automatically.

To revisit any entry, remove it from the table and run the audit again.

| File/Dir | Decision | Reason | Date |
|---|---|---|---|
| `~/.claude.json` | skip | Machine state, auth tokens, session data — not authored config | 2026-06-30 |
| `~/.codex/config.toml` | skip | Mostly app-generated with hardcoded machine paths; only model and UI prefs are authored, not worth the noise | 2026-06-30 |
| `~/.codex/rules/default.rules` | skip | Session-accumulated permission grants, project-specific, not authored — rebuilds naturally on a new machine | 2026-06-30 |
| `~/.gemini/settings.json` | skip | Single auth preference line, trivial to recreate | 2026-06-30 |
| `~/.vscode-oss/argv.json` | skip | Machine-specific crash reporter UUID; no intentional flags set | 2026-06-30 |
| `~/.cursor/argv.json` | skip | App-generated boilerplate; no intentional flags set | 2026-06-30 |
| `~/.ollama/config.json` | skip | App-written runtime state (last model, last selection) — not authored config | 2026-06-30 |
