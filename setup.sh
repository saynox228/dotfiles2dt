#!/usr/bin/env bash

set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "🚀 Setting up DOTFILES..."

# ---------------------------------------------------------
# Sudo check
# ---------------------------------------------------------

if ! sudo -v; then
    echo "❌ sudo access required"
    exit 1
fi

# ---------------------------------------------------------
# System update
# ---------------------------------------------------------

echo "📦 Updating system..."

sudo apt-get update -yq
sudo apt-get upgrade -yq

# ---------------------------------------------------------
# Packages
# ---------------------------------------------------------

PACKAGES=(
    git
    zsh
    vim
    gh
    curl
    wget
    btop
    neovim
    fzf
    eza
    build-essential
    python3
    python3-pip
    python3-venv
)

echo "📦 Installing packages..."

sudo apt-get install -yq "${PACKAGES[@]}"

# ---------------------------------------------------------
# Clone dotfiles
# ---------------------------------------------------------

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/saynox228/dotfiles2dt.git"

if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "📂 Updating dotfiles..."
    git -C "$DOTFILES_DIR" pull --ff-only origin main
else
    echo "📥 Cloning dotfiles..."
    git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR"
fi

# ---------------------------------------------------------
# Install Oh My Zsh
# ---------------------------------------------------------

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "⚡ Installing Oh My Zsh..."

    RUNZSH=no \
    CHSH=no \
    KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ---------------------------------------------------------
# Plugins
# ---------------------------------------------------------

clone_if_missing() {
    local repo="$1"
    local target="$2"

    if [ ! -d "$target" ]; then
        git clone --depth=1 "$repo" "$target"
    fi
}

clone_if_missing \
"https://github.com/zsh-users/zsh-autosuggestions" \
"$ZSH_CUSTOM/plugins/zsh-autosuggestions"

clone_if_missing \
"https://github.com/zsh-users/zsh-syntax-highlighting.git" \
"$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ---------------------------------------------------------
# Powerlevel10k
# ---------------------------------------------------------

clone_if_missing \
"https://github.com/romkatv/powerlevel10k.git" \
"$ZSH_CUSTOM/themes/powerlevel10k"

# ---------------------------------------------------------
# Symlinks
# ---------------------------------------------------------

create_symlink() {
    local source_file="$1"
    local target_file="$2"

    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo "📦 Backing up $target_file"
        mv "$target_file" "${target_file}.bak.$(date +%s)"
    fi

    ln -sfn "$source_file" "$target_file"

    echo "✅ Linked $target_file"
}

create_symlink \
"$DOTFILES_DIR/.zshrc" \
"$HOME/.zshrc"

# ---------------------------------------------------------
# Change shell
# ---------------------------------------------------------

if command -v zsh >/dev/null 2>&1; then
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

    if [ "$CURRENT_SHELL" != "$(which zsh)" ]; then
        echo "🔄 Changing default shell to Zsh..."

        chsh -s "$(which zsh)" "$USER" || true
    fi
fi

echo "✅ setup.sh completed!"
echo "Restart terminal or run:"
echo "exec zsh"
