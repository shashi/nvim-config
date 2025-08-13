#!/bin/bash

# Simple setup script for Neovim configuration
set -e

echo "Setting up minimal Neovim configuration..."

# Create config directory
mkdir -p ~/.config/nvim

# Copy init.vim
cp init.vim ~/.config/nvim/

# Install vim-plug if not already installed
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    echo "Installing vim-plug..."
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo ""
echo "Setup complete! Next steps:"
echo "1. Open Neovim"
echo "2. Run :PlugInstall to install plugins"
echo "3. Run :Mason and install 'basedpyright' for Python support"
echo ""
echo "Optional: Install Python tools with 'pip install black ruff'"