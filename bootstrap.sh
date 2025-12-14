#!/usr/bin/env bash

# Define the repository URL
REPO_URL="https://github.com/BitWise-0x/.dot-files"
DOTFILES_DIR="$HOME/.dotfiles"

# Clone the repository if it doesn't exist
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles repository..."
    if ! git clone --verbose "$REPO_URL" "$DOTFILES_DIR"; then
        echo "Failed to clone the repository. Please check your network connection and access rights."
        exit 1
    fi
else
    echo "Dotfiles repository already cloned. Pulling latest changes..."
    if ! git -C "$DOTFILES_DIR" pull --verbose; then
        echo "Failed to pull the latest changes. Please check your network connection and access rights."
        exit 1
    fi
fi

# Function to sync dotfiles
function syncDotfiles() {
    rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude ".gitignore" \
        --exclude ".osx" \
        --exclude "bootstrap.sh" \
        --exclude "setup.sh" \
        --exclude "README.md" \
        -avh --no-perms "$DOTFILES_DIR/" "$HOME/"
}

# Function to install fonts
function installFonts() {
    FONT_DIR="$HOME/.fonts"
    if [[ -d "$FONT_DIR" ]]; then
        echo "Installing fonts from $FONT_DIR..."
        cp "$FONT_DIR"/* "$HOME/Library/Fonts/"
        echo "Fonts installed."
    else
        echo "No fonts to install."
    fi
}

# Prompt for confirmation
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
    syncDotfiles
    installFonts
    SYNCED=true
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        syncDotfiles
        installFonts
        SYNCED=true
    else
        SYNCED=false
        echo "No files were overwritten."
    fi
fi

# Only start a new shell session if files were synced
if [ "$SYNCED" = true ]; then
    # Check the default system shell and start a new shell session
    current_shell=$(basename "$SHELL")

    if [ "$current_shell" = "zsh" ]; then
        echo "Starting a new Zsh session..."
        zsh -i
    elif [ "$current_shell" = "bash" ]; then
        echo "Starting a new Bash session..."
        bash --login
    fi
    echo "Dotfiles installation complete."
fi