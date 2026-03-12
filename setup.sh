#!/usr/bin/env bash
#
# setup.sh — Fresh macOS dev environment setup.
#
# Installs Xcode CLT, Homebrew, packages, Oh-My-Zsh, fonts, and iTerm2 themes.
# Run this first on a new system, then use ./bootstrap.sh to sync configs.
#

set -uo pipefail

# Track failures but don't exit on them
BREW_FAILURES=()
brew_install() {
    if ! brew install "$@" 2>&1; then
        BREW_FAILURES+=("$*")
        echo "  ⚠ brew install $* failed — continuing"
    fi
}

# ============================================================================
# 1. Xcode Command Line Tools
# ============================================================================

if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for CLT installation to complete (timeout after 30 minutes)
    tries=0
    until xcode-select -p &>/dev/null; do
        if (( tries++ >= 360 )); then
            echo "ERROR: Xcode CLT installation timed out after 30 minutes."
            exit 1
        fi
        sleep 5
    done
    sudo softwareupdate -i -a
fi

# ============================================================================
# 2. Homebrew
# ============================================================================

if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew upgrade
HOMEBREW_PREFIX=$(brew --prefix)

# ============================================================================
# 3. Languages & Version Management
# ============================================================================

brew_install python@3.12
brew_install virtualenv
brew_install virtualenvwrapper
echo 'Add export WORKON_HOME=~/.virtualenvs and source virtualenvwrapper.sh to .zshrc or .bashrc'
# Usage: mkvirtualenv -p python3.12 ENVNAME && workon ENVNAME

brew_install node
brew_install nvm
# Usage: mkdir -p ~/.nvm && nvm install 22 && nvm use 22

# ============================================================================
# 4. GNU Core Utilities & CLI Tools
# ============================================================================

# GNU core utilities (macOS ships outdated versions)
# Add $(brew --prefix coreutils)/libexec/gnubin to $PATH
brew_install coreutils
ln -sf "${HOMEBREW_PREFIX}/bin/gsha256sum" "${HOMEBREW_PREFIX}/bin/sha256sum" 2>/dev/null || true

# GnuPG for PGP-signing commits
brew_install gnupg

# Useful CLI utilities
brew_install wget
brew_install moreutils
brew_install tree
brew_install rsync

# GNU find, locate, updatedb, xargs (g-prefixed)
brew_install findutils

# GNU sed
brew_install gnu-sed

# Modern Bash
brew_install bash
brew_install bash-completion2

# Add brew-installed bash to allowed shells
if ! grep -Fq "${HOMEBREW_PREFIX}/bin/bash" /etc/shells; then
    echo "${HOMEBREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    # chsh -s "${HOMEBREW_PREFIX}/bin/bash"  # sticking with zsh
fi

# Updated macOS tools
brew_install vim
brew_install grep
brew_install openssh
brew_install screen
brew_install php
brew_install gmp
brew_install gnu-tar

# Font tools
brew tap bramstein/webfonttools
brew_install sfnt2woff
brew_install sfnt2woff-zopfli
brew_install woff2

# ============================================================================
# 5. Security / CTF Tools
# ============================================================================

brew_install aircrack-ng
brew_install bfg
# brew_install binutils
# brew_install binwalk
brew_install cifer
# brew_install dex2jar
brew_install dns2tcp
# brew_install fcrackzip
# brew_install foremost
brew_install hashcat
# brew_install hydra
brew_install ruby
brew_install john
brew_install knock
brew_install netpbm
brew_install nmap
brew_install pngcheck
brew_install socat
brew_install sqlmap
brew_install tcpflow
brew_install tcpreplay
brew_install tcptrace
# brew_install ucspi-tcp  # tcpserver etc.
brew_install xpdf
brew_install xz
brew_install ack
brew_install lynx

# ============================================================================
# 6. Git
# ============================================================================

brew_install git
brew_install git-lfs
brew_install gs

# ============================================================================
# 7. Docker & Colima
# ============================================================================

brew_install docker
brew_install docker-compose
brew_install docker-completion
brew_install docker-buildx
# Colima — lightweight VM for local Docker context (in lieu of Docker Desktop)
brew_install colima

# ============================================================================
# 8. Other Tools
# ============================================================================

# Fuzzy finder for shell — https://github.com/junegunn/fzf
brew_install fzf
if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/install" ]]; then
    "${HOMEBREW_PREFIX}/opt/fzf/install" --all --no-update-rc
fi

brew_install cowsay
brew_install --cask --appdir="/Applications" iterm2
brew_install ffmpeg
brew_install asitop
# brew_install --cask --appdir="/Applications" multipass
# brew_install --cask --appdir="/Applications" visual-studio-code
# brew_install --cask --appdir="/Applications" spotify
brew_install --cask uninstallpkg  # GUI uninstaller for .pkg files

brew cleanup

# ============================================================================
# 9. Oh-My-Zsh
# ============================================================================

ZSH="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="${ZSH}/custom"

if [[ ! -d "$ZSH" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Plugins
[[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
[[ -d "${ZSH_CUSTOM}/plugins/zsh-autocomplete" ]] || \
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM}/plugins/zsh-autocomplete"
[[ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

# Theme — powerlevel10k
# To configure, run `p10k configure` or edit ~/.p10k.zsh
[[ -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]] || \
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
echo 'Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc'

# ============================================================================
# 10. Fonts
# ============================================================================

FONT_DIR="${HOME}/.fonts"
mkdir -p "$FONT_DIR"
mkdir -p "$HOME/Library/Fonts"

MESLO_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
declare -a MESLO_FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)
for font in "${MESLO_FONTS[@]}"; do
    if [[ ! -f "${FONT_DIR}/${font}" ]]; then
        curl -fsSL -o "${FONT_DIR}/${font}" "${MESLO_BASE}/$(echo "$font" | sed 's/ /%20/g')"
    fi
done

cp "${FONT_DIR}/"* "$HOME/Library/Fonts/"
echo 'Select font in iTerm2: Preferences > Profile > Text > Font > MesloLGS NF'
echo 'Select font in VSCode: settings.json > "editor.fontFamily": "MesloLGS NF"'

# ============================================================================
# 11. iTerm2 Color Schemes
# ============================================================================

ITERM_SCHEMES="${HOME}/Downloads/iterm2-color-schemes"
if [[ ! -d "$ITERM_SCHEMES" ]]; then
    git clone https://github.com/mbadolato/iTerm2-Color-Schemes "$ITERM_SCHEMES"
fi
"${ITERM_SCHEMES}/tools/import-scheme.sh" -v "${ITERM_SCHEMES}/schemes/"*
rm -rf "$ITERM_SCHEMES"
echo "Restart iTerm2 and set theme: Preferences > Profile > Colors > Color Presets > Argonaut"

# ============================================================================
# Done
# ============================================================================

echo ""
if (( ${#BREW_FAILURES[@]} > 0 )); then
    echo "⚠ The following brew packages failed to install:"
    printf "  - %s\n" "${BREW_FAILURES[@]}"
    echo ""
fi
echo "#####################################"
echo "  Run ./bootstrap.sh to sync configs"
echo "#####################################"
