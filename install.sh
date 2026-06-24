#!/bin/bash
set -e

echo "Bootstrapping Mac..."

# 1. Xcode Command Line Tools (required before Homebrew and git)
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    CLT=$(softwareupdate -l | grep -B 1 -E "Command Line Tools" | awk -F"*" '/^ *\*/{print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n1)
    softwareupdate -i "$CLT" --verbose
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. Load brew into PATH for this session (handles both Apple Silicon and Intel)
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"

# 4. Install git and stow
brew install git stow

# 5. Clone dotfiles
DOTFILES_DIR="$HOME/Developer/dotfiles"
[[ ! -d "$DOTFILES_DIR" ]] && git clone https://github.com/dev-rix/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

# 6. Install all apps and fonts from Brewfile
brew bundle --file=./Brewfile

# 7. Prevent stow from folding parent dirs into symlinks
mkdir -p ~/.config/nvim ~/.config/wezterm ~/.config/karabiner

# 8. Symlink all configs
stow -v -R --no-folding --dotfiles -t ~ zsh vim nvim wezterm karabiner

# 9. Trust third-party tap formulas
brew trust --formula nikitabobko/tap/aerospace
brew trust --formula notwadegrimridge/brew/pingplace

echo "Done. Open a new terminal to apply zsh config."
