# dotfiles

My macOS dotfiles, managed with [stow](https://www.gnu.org/software/stow/).

## Install

Paste this into a terminal on a fresh macOS install:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-rix/dotfiles/main/install.sh)"
```

This will:
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Install `git` and `stow`
4. Clone this repo to `~/Developer/dotfiles`
5. Install all apps and fonts via `Brewfile`
6. Symlink all configs into `~`

## Configs

| Directory   | Target                   |
|-------------|--------------------------|
| `zsh/`      | `~/.zshrc`               |
| `nvim/`     | `~/.config/nvim/`        |
| `vim/`      | `~/.vimrc`               |
| `wezterm/`  | `~/.config/wezterm/`     |
| `karabiner/`| `~/.config/karabiner/`   |

## Sync

After making changes, run `dotsync` to dump the Brewfile, commit, and push:

```sh
dotsync
```
