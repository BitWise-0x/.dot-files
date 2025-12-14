# Dotfiles Repository

This repository contains my personal configuration files and setup scripts for macOS. It helps automate the installation and configuration of various tools and settings to create a consistent development environment.

## Setup


### Scripts

- **`setup.sh`**: This script installs essential tools and applications using Homebrew. It sets up the environment with the necessary software and configurations.

  - **Usage**: Run `setup.sh` to install and configure the environment.

- **`bootstrap.sh`**: This script synchronizes your dotfiles from the repository to your home directory.

  - **Usage**: Run `bootstrap.sh` to sync your dotfiles and install fonts.

## Using

```bash
git clone https://github.com/BitWise-0x/.dot-files && cd .dot-files && ./bootstrap.sh
```

## Features

- **Tool Installation**: Installs / updates a variety of tools and utilities using Homebrew, such as Python, GNU core utilities, Docker, iTerm2, and more.
- **Zsh Configuration**: Sets up Oh-My-Zsh with plugins and themes, including Powerlevel10k.
- **Font Installation**: Automatically installs fonts used by Oh-My-Zsh,Vscode, iTerm2, etc.
- **iTerm2 Customization**: Includes color schemes for iTerm2.

## Screenshot

![Screen Shot 2024-10-24 at 02 00 50 AM](https://github.com/user-attachments/assets/f37972d2-316f-496a-88e5-9d5634d08f1a)


*This capture shows the terminal appearance after running the scripts.*


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Feel free to customize this `README.md` to better suit your needs or to provide additional information specific to your setup.
