#!/bin/bash

set -e

echo "🚀 Setting up DOTFILES..."

# ---------------------------------------------------------
# System update
# ---------------------------------------------------------

echo "📦 Updating system..."
sudo apt update && sudo apt upgrade -y

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
sudo apt install -y "${PACKAGES[@]}"

# ---------------------------------------------------------
# Clone dotfiles
# ---------------------------------------------------------

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/saynox228/dotfiles2dt.git"

if [ -d "$DOTFILES_DIR" ]; then
    echo "📂 Updating dotfiles..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    echo "📥 Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# ---------------------------------------------------------
# Install Oh My Zsh
# ---------------------------------------------------------

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "⚡ Installing Oh My Zsh..."
    RUNZSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh already installed."
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# ---------------------------------------------------------
# Plugins
# ---------------------------------------------------------

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ---------------------------------------------------------
# Powerlevel10k
# ---------------------------------------------------------

P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$P10K_DIR"
fi

# ---------------------------------------------------------
# Symlinks
# ---------------------------------------------------------

create_symlink() {
    local source_file="$1"
    local target_file="$2"

    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo "📦 Backing up $target_file"
        mv "$target_file" "${target_file}.backup"
    fi

    ln -sf "$source_file" "$target_file"
    echo "✅ Linked $target_file"
}

create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# ---------------------------------------------------------
# Change shell
# ---------------------------------------------------------

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
fi

echo "✅ setup.sh completed!"
echo "Restart terminal or run:"
echo "source ~/.zshrc"
