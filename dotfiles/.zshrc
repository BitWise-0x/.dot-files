# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Exports - History
# https://unix.stackexchange.com/questions/273861/unlimited-history-in-zsh
export HISTFILE=~/.zsh_history
export HISTSIZE=500000
export SAVEHIST=$HISTSIZE


# Exports - Other
# Add `~/bin` to the `$PATH`
export PATH=/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH
# Homebrew
if [ -x /opt/homebrew/bin/brew ]; then
    # Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    # Intel
    eval "$(/usr/local/bin/brew shellenv)"
fi
# GNU core utilities update from brew
export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
# Python
export PATH="$HOMEBREW_PREFIX/opt/python/libexec/bin:$PATH"
# Python env
export WORKON_HOME=~"/.virtualenvs"
# Only load virtualenvwrapper if it exists
if [ -f "$HOMEBREW_PREFIX/bin/virtualenvwrapper.sh" ]; then
  source "$HOMEBREW_PREFIX/bin/virtualenvwrapper.sh"
elif command -v virtualenvwrapper.sh &> /dev/null; then
  source virtualenvwrapper.sh
fi
# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'
# Node / NVM (loaded by the oh-my-zsh nvm plugin, lazily; .nvmrc autoload on cd)
export NVM_DIR="$HOME/.nvm"
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' lazy-cmd pnpm npx corepack
zstyle ':omz:plugins:nvm' autoload yes
zstyle ':omz:plugins:nvm' silent-autoload yes
# Set language character set
export LANG='en_US.UTF-8'
# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"
# Docker: active context is colima (~/.docker/config.json); DOCKER_HOST unset so `docker context use` works
# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'
# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)
# Path to your Oh My Zsh installation  - ZSH only!!!
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
# git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
plugins=(git nvm zsh-autosuggestions zsh-autocomplete zsh-syntax-highlighting)

# custom completions dropped here by utilities; must be on fpath before compinit runs (oh-my-zsh runs it)
fpath+=~/.zfunc

# source oh-my-zsh (must be after plugins array)
source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export VISUAL='vim'
#   export EDITOR="$VISUAL"
# else
#   export EDITOR='nvim'
# fi


# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,zsh_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Custom Aliases
# source ~/.custom/init.sh

# Case-insensitive globbing (used in pathname expansion)
setopt NO_CASE_GLOB
# Append to the Zsh history file, rather than overwriting it
setopt APPEND_HISTORY
# Autocorrect typos in path names when using `cd` autoCD
setopt AUTO_CD
# Enable recursive globbing
setopt GLOBSTAR_SHORT


# FZF
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi


# Python env activation hook: if a .venv file is present, workon its contents
# (.nvmrc handling is the nvm plugin's autoload, configured above)
# Example of .venv content (must exist):
#   ultimate-scraper
autoload -U add-zsh-hook

workon_on_cd() {
  if [ -f .venv ]; then
    workon $(cat .venv)
  fi
}
# Only add the hook if it hasn't been added already
if [[ -z "${(M)chpwd_functions[@]:#workon_on_cd}" ]]; then
  add-zsh-hook chpwd workon_on_cd
fi
workon_on_cd

# Cloudflare — wrangler authenticates via OAuth (`wrangler login`); no API token in the env.
export CLOUDFLARE_ACCOUNT_ID="f38ff5f5924cc421c716769450235c96"
