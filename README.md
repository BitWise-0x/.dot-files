# Dotfiles Repository

Personal configuration files and setup scripts for macOS. Automates installation and configuration of development tools, shell environments, and editor settings.

## Quick Start

```bash
git clone https://github.com/BitWise-0x/.dot-files && cd .dot-files && ./bootstrap.sh
```

## Scripts

### `setup.sh`

Installs essential tools and applications using Homebrew. Run this first on a fresh system.

```bash
./setup.sh
```

### `bootstrap.sh`

Syncs dotfiles from the repository to your home directory and installs fonts.

```bash
./bootstrap.sh          # Interactive mode (prompts for confirmation)
./bootstrap.sh --force  # Skip confirmation prompt
```

## Features

### Shell Configuration
- **Zsh**: Oh-My-Zsh with plugins (autosuggestions, autocomplete, syntax-highlighting) and Powerlevel10k theme
- **Bash**: Custom prompt, completions, and configurations

### Development Tools (via Homebrew)
- **Languages**: Python 3.12, Node.js, PHP, Ruby
- **Version Management**: nvm, virtualenv, virtualenvwrapper
- **Containers**: Docker, Docker Compose, Colima (lightweight Docker Desktop alternative)
- **Git**: git, git-lfs, GnuPG for commit signing
- **CLI Utilities**: GNU coreutils, findutils, sed, grep, wget, rsync, fzf, tree, vim

### Security/CTF Tools
- Network: nmap, aircrack-ng, tcpflow, tcpreplay, tcptrace, socat, dns2tcp
- Cracking: hashcat, john, sqlmap
- Analysis: xpdf, pngcheck, knock, cifer

### Editor/Terminal Configuration
- **VSCode**: Settings and extensions configuration
- **iTerm2**: Color schemes (auto-imported), font configuration
- **Vim**: Custom `.vimrc` and plugins
- **Warp**: Theme configuration
- **Windows Terminal**: Settings (for cross-platform use)

### Fonts
- MesloLGS NF (Regular, Bold, Italic, Bold Italic) - optimized for Powerlevel10k

## Screenshot

![Screen Shot 2024-10-24 at 02 00 50 AM](https://github.com/user-attachments/assets/f37972d2-316f-496a-88e5-9d5634d08f1a)

*Terminal appearance after running the scripts.*

## License

MIT License - see [LICENSE](LICENSE) for details.
