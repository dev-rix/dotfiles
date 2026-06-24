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

# 4. Enable Touch ID for sudo (sudo_local survives macOS updates)
if ! grep -q "pam_tid" /etc/pam.d/sudo_local 2>/dev/null; then
    if [[ -f /etc/pam.d/sudo_local.template ]]; then
        sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
        sudo sed -i '' 's/#auth/auth/' /etc/pam.d/sudo_local
    fi
fi

# 5. Install git and stow
brew install git stow

# 6. Clone dotfiles
DOTFILES_DIR="$HOME/Developer/dotfiles"
[[ ! -d "$DOTFILES_DIR" ]] && git clone https://github.com/dev-rix/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

# 7. Trust third-party tap formulas (must happen before brew bundle)
brew trust --formula nikitabobko/tap/aerospace
brew trust --formula notwadegrimridge/brew/pingplace

# 8. Install all apps and fonts from Brewfile
brew bundle --file=./Brewfile

# 9. Prevent stow from folding parent dirs into symlinks
mkdir -p ~/.config/nvim ~/.config/wezterm ~/.config/karabiner ~/.config/gh

# 10. Remove any plain files that would block stow (macOS or prior steps may create these)
for f in ~/.zshrc ~/.zprofile ~/.vimrc ~/.gitconfig ~/.gitignore_global ~/.aerospace.toml ~/.config/karabiner/karabiner.json; do
    [[ -f "$f" && ! -L "$f" ]] && rm -f "$f"
done

# 11. Symlink all configs
stow -v -R --no-folding --dotfiles -t ~ zsh vim nvim wezterm karabiner git aerospace gh

# 12. Git identity (written to a local-only file so email stays out of the repo)
read -rp "Git email: " GIT_EMAIL
echo -e "[user]\n\temail = $GIT_EMAIL" > ~/.gitconfig.local

# 13. macOS preferences
defaults write com.apple.screencapture location ~/Downloads

echo "Done. Open a new terminal to apply zsh config."
