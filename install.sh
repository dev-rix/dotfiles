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

# 5. SSH key
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    read -rp "Email for SSH key: " SSH_EMAIL
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f ~/.ssh/id_ed25519 -N ""
    echo ""
    echo "Add this public key to GitHub before continuing:"
    echo "https://github.com/settings/keys"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
    read -rp "Press Enter once the key is added to GitHub..."
fi

# 6. Clone dotfiles
DOTFILES_DIR="$HOME/Developer/dotfiles"
[[ ! -d "$DOTFILES_DIR" ]] && git clone https://github.com/dev-rix/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

# 7. Install all apps and fonts from Brewfile
brew bundle --file=./Brewfile

# 8. Prevent stow from folding parent dirs into symlinks
mkdir -p ~/.config/nvim ~/.config/wezterm ~/.config/karabiner ~/.config/gh

# 9. Remove any plain files that would block stow (macOS or prior steps may create these)
for f in ~/.zshrc ~/.zprofile ~/.vimrc ~/.gitconfig ~/.gitignore_global ~/.aerospace.toml; do
    [[ -f "$f" && ! -L "$f" ]] && rm -f "$f"
done

# 10. Symlink all configs
stow -v -R --no-folding --dotfiles -t ~ zsh vim nvim wezterm karabiner git aerospace gh

# 11. Git identity (written to a local-only file so email stays out of the repo)
read -rp "Git email: " GIT_EMAIL
echo -e "[user]\n\temail = $GIT_EMAIL" > ~/.gitconfig.local

# 12. macOS preferences
defaults write com.apple.screencapture location ~/Downloads

# 13. Trust third-party tap formulas
brew trust --formula nikitabobko/tap/aerospace
brew trust --formula notwadegrimridge/brew/pingplace

echo "Done. Open a new terminal to apply zsh config."
