#!/bin/bash
set -e

echo "🚀 Bootstrapping Mac..."

# 1. Homebrew & Architecture Check
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. Basic Tools
brew install git stow

# 3. Clone Repo (Update YOUR_USER)
DOTFILES_DIR="$HOME/Developer/dotfiles"
[[ ! -d "$DOTFILES_DIR" ]] && git clone https://github.com/dev-rix/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

# 4. Install Apps & Fonts
brew bundle --file=./Brewfile

# 5. Prevent Stow Folding
mkdir -p ~/.config/nvim ~/.config/wezterm

# 6. Symlink
stow -v -R --no-folding --dotfiles -t ~ zsh vim nvim wezterm

echo "✅ Done! Verify with: ls -la ~"
