#!/usr/bin/env bash
#
# bootstrap.sh — Syncs dotfiles and configs from this repo to your system.
#
# Usage: ./bootstrap.sh [--force|-f] [--no-brew]
#
# Reads from the organized repo structure:
#   dotfiles/  → ~/           (shell, editor, CLI configs)
#   vscode/    → ~/Library/Application Support/Code/User/
#   tools/     → ~/.docker/, ~/.colima/, ~/.config/gh/, ~/.config/git/, ~/
#   homebrew/  → brew bundle install
#   .fonts/    → ~/Library/Fonts/
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
SKIP_BREW=false

# Parse flags
for arg in "$@"; do
    case "$arg" in
        --no-brew) SKIP_BREW=true ;;
    esac
done

# Define the repository URL
REPO_URL="https://github.com/BitWise-0x/.dot-files"
DOTFILES_DIR="$HOME/.dotfiles"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC}  $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# --- Clone or pull repo if running from a fresh system ---
if [[ ! -d "$REPO_DIR/.git" ]]; then
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        echo "Cloning dotfiles repository..."
        if ! git clone --verbose "$REPO_URL" "$DOTFILES_DIR"; then
            echo "Failed to clone. Check network and access rights."
            exit 1
        fi
    else
        echo "Pulling latest changes..."
        git -C "$DOTFILES_DIR" pull --verbose || true
    fi
    REPO_DIR="$DOTFILES_DIR"
fi

sync_all() {
    # ==================================================================
    # 1. Dotfiles (shell & editor configs)
    # ==================================================================
    info "--- Dotfiles ---"

    if [[ -d "$REPO_DIR/dotfiles" ]]; then
        # Single dotfiles → ~/
        for f in "$REPO_DIR"/dotfiles/.*; do
            [[ -f "$f" ]] || continue
            name="$(basename "$f")"
            [[ "$name" = ".DS_Store" ]] && continue
            cp "$f" "$HOME/$name"
            log "~/$name"
        done

        # .custom/
        if [[ -d "$REPO_DIR/dotfiles/.custom" ]]; then
            cp -r "$REPO_DIR/dotfiles/.custom" "$HOME/.custom"
            log "~/.custom/"
        fi

        # .zfunc/
        if [[ -d "$REPO_DIR/dotfiles/.zfunc" ]]; then
            cp -r "$REPO_DIR/dotfiles/.zfunc" "$HOME/.zfunc"
            log "~/.zfunc/"
        fi

        # .warp/
        if [[ -d "$REPO_DIR/dotfiles/.warp" ]]; then
            mkdir -p "$HOME/.warp"
            cp -r "$REPO_DIR/dotfiles/.warp/"* "$HOME/.warp/" 2>/dev/null || true
            log "~/.warp/"
        fi

        # .powershell/
        if [[ -d "$REPO_DIR/dotfiles/.powershell" ]]; then
            cp -r "$REPO_DIR/dotfiles/.powershell" "$HOME/.powershell"
            log "~/.powershell/"
        fi

        # .windows-terminal/
        if [[ -d "$REPO_DIR/dotfiles/.windows-terminal" ]]; then
            cp -r "$REPO_DIR/dotfiles/.windows-terminal" "$HOME/.windows-terminal"
            log "~/.windows-terminal/"
        fi

        # .vim/colors/
        if [[ -d "$REPO_DIR/dotfiles/.vim/colors" ]]; then
            mkdir -p "$HOME/.vim"
            cp -r "$REPO_DIR/dotfiles/.vim/colors" "$HOME/.vim/colors"
            log "~/.vim/colors/"
        fi

        # .ssh/config (preserve permissions)
        if [[ -f "$REPO_DIR/dotfiles/.ssh/config" ]]; then
            mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
            cp "$REPO_DIR/dotfiles/.ssh/config" "$HOME/.ssh/config"
            chmod 600 "$HOME/.ssh/config"
            log "~/.ssh/config"
        fi

        # .oh-my-zsh (p10k theme only — requires Oh-My-Zsh + p10k to be installed)
        P10K="$REPO_DIR/dotfiles/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
        if [[ -f "$P10K" ]]; then
            if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
                cp "$P10K" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
                log "~/.oh-my-zsh (p10k theme)"
            else
                warn "Oh-My-Zsh powerlevel10k not installed — skipping p10k theme sync"
            fi
        fi

        # local/share/calendar/
        if [[ -d "$REPO_DIR/dotfiles/local/share/calendar" ]]; then
            mkdir -p "$HOME/local/share"
            cp -r "$REPO_DIR/dotfiles/local/share/calendar" "$HOME/local/share/calendar"
            log "~/local/share/calendar/"
        fi
    else
        warn "dotfiles/ not found in repo"
    fi

    # ==================================================================
    # 2. VSCode
    # ==================================================================
    info "--- VSCode ---"

    if [[ -d "$REPO_DIR/vscode" ]]; then
        VSCODE_USER="$HOME/Library/Application Support/Code/User"
        mkdir -p "$VSCODE_USER"

        for f in settings.json keybindings.json mcp.json; do
            if [[ -f "$REPO_DIR/vscode/$f" ]]; then
                cp "$REPO_DIR/vscode/$f" "$VSCODE_USER/$f"
                log "VSCode $f"
            fi
        done

        if [[ -d "$REPO_DIR/vscode/snippets" ]]; then
            cp -r "$REPO_DIR/vscode/snippets" "$VSCODE_USER/snippets"
            log "VSCode snippets/"
        fi

        # Install extensions
        if [[ -f "$REPO_DIR/vscode/extensions.txt" ]] && command -v code &>/dev/null; then
            info "Installing VSCode extensions..."
            while IFS= read -r ext; do
                [[ -z "$ext" ]] && continue
                code --install-extension "$ext" --force &>/dev/null || warn "Extension: $ext"
            done < "$REPO_DIR/vscode/extensions.txt"
            log "VSCode extensions"
        fi
    else
        warn "vscode/ not found in repo"
    fi

    # ==================================================================
    # 3. Tool Configs
    # ==================================================================
    info "--- Tool Configs ---"

    if [[ -d "$REPO_DIR/tools" ]]; then
        # Docker
        if [[ -f "$REPO_DIR/tools/docker/config.json" ]]; then
            mkdir -p "$HOME/.docker"
            cp "$REPO_DIR/tools/docker/config.json" "$HOME/.docker/config.json"
            log "Docker config"
        fi

        # Colima
        if [[ -f "$REPO_DIR/tools/colima/colima.yaml" ]]; then
            mkdir -p "$HOME/.colima/default"
            cp "$REPO_DIR/tools/colima/colima.yaml" "$HOME/.colima/default/colima.yaml"
            log "Colima config"
        fi

        # GitHub CLI
        if [[ -f "$REPO_DIR/tools/gh/config.yml" ]]; then
            mkdir -p "$HOME/.config/gh"
            cp "$REPO_DIR/tools/gh/config.yml" "$HOME/.config/gh/config.yml"
            log "GitHub CLI config"
        fi

        # Git ignore (XDG)
        if [[ -f "$REPO_DIR/tools/git/ignore" ]]; then
            mkdir -p "$HOME/.config/git"
            cp "$REPO_DIR/tools/git/ignore" "$HOME/.config/git/ignore"
            log "Git ignore"
        fi

        # Git ignore (global legacy)
        if [[ -f "$REPO_DIR/tools/git/gitignore_global" ]]; then
            cp "$REPO_DIR/tools/git/gitignore_global" "$HOME/.gitignore_global"
            log "Git ignore (global)"
        fi
    else
        warn "tools/ not found in repo"
    fi

    # ==================================================================
    # 4. Homebrew
    # ==================================================================
    info "--- Homebrew ---"

    if [[ "$SKIP_BREW" = true ]]; then
        warn "Homebrew skipped (--no-brew)"
    elif [[ -f "$REPO_DIR/homebrew/Brewfile" ]] && command -v brew &>/dev/null; then
        brew bundle --no-upgrade --file="$REPO_DIR/homebrew/Brewfile" 2>/dev/null && log "Brewfile" || warn "Some brew packages failed"
    else
        warn "Brewfile or Homebrew not found"
    fi

    # ==================================================================
    # 5. Fonts
    # ==================================================================
    info "--- Fonts ---"

    if [[ -d "$REPO_DIR/.fonts" ]]; then
        mkdir -p "$HOME/Library/Fonts"
        font_count=0
        while IFS= read -r -d '' font_file; do
            cp "$font_file" "$HOME/Library/Fonts/" && ((font_count++)) || warn "Failed to copy $(basename "$font_file")"
        done < <(find "$REPO_DIR/.fonts" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.woff" -o -name "*.woff2" \) -print0)
        if (( font_count > 0 )); then
            log "Fonts installed ($font_count files)"
        else
            warn "No fonts to install"
        fi
    else
        warn ".fonts/ not found in repo"
    fi
}

# --- Prompt or force ---
echo ""
if [[ "${1:-}" = "--force" || "${1:-}" = "-f" ]]; then
    sync_all
else
    info "This will overwrite existing config files in your home directory."
    read -rp "Proceed? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sync_all
    else
        info "Cancelled."
        exit 0
    fi
fi

echo ""
info "Bootstrap complete. Restart your shell to apply changes."
