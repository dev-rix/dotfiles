---
name: dotfiles-audit
description: Scans ~ and the dotfiles repo to find config files that should be tracked but aren't. Filters against a skip list of past decisions and generates a report. Invoke when you want to audit your dotfiles coverage.
---

# Dotfiles Audit

Audit the user's home directory against their dotfiles repo at `~/Developer/dotfiles` to find config files worth tracking that aren't yet.

## Steps

### 1. Load the skip list
Read `~/Developer/dotfiles/audit/skip-list.md`. Every entry there is a past decision — do not surface those items again unless the user explicitly asks to revisit them.

### 2. Scan `~/` for dotfiles and config
Look at:
- Hidden files directly in `~/` (e.g. `~/.zshrc`, `~/.gitconfig`)
- `~/.config/` subdirectories
- Tool-specific dirs that contain config the user authors (not cache, not runtime state, not credentials)

Automatically exclude without listing: `~/.cache`, `~/.Trash`, `~/.DS_Store`, `~/.zsh_history`, `~/.zcompdump`, `~/.zsh_sessions`, `~/.CFUserTextEncoding`, private keys in `~/.ssh/` (but not `~/.ssh/config`).

### 3. Check what's already tracked
Scan `~/Developer/dotfiles` — look at the stow module directories and their `dot-*` contents to understand what's covered.

### 4. Generate the report
Produce two sections:

**Candidates** — files/dirs not in the repo and not on the skip list. For each, give a one-line reason it might be worth adding and a one-line reason it might not be. Let the user decide.

**Already tracked** — brief confirmation of covered items (one line each, no elaboration needed).

### 5. Record decisions
After presenting the report, ask the user if any items from this session should be added to the skip list. If yes, append them to `~/Developer/dotfiles/audit/skip-list.md` using the existing table format, with today's date and the reason the user gave.
