# thanks timo
export PS1="\[\033[1;36m\]\u\[\033[01;37m\]@\[\033[01;34m\]\h\[\033[01;30m\][\[\033[01;37m\]\w\[\033[01;30m\]]\[\033[01;32m\]\[\033[00m\]+ "

# VSCode Shell Integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"


# History
# http://lpetr.org/blog/archives/preserve-bash-history
export HISTSIZE=50000
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"


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
export HOMEBREW_PREFIX=$(brew --prefix)
# GNU core utilities update from brew
# export $(brew --prefix coreutils)/libexec/gnubin:$PATH
export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
# Ruby
export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
# Python
export PATH="$HOMEBREW_PREFIX/opt/python/libexec/bin:$PATH"
# Python env
export WORKON_HOME=~"/.virtualenvs"
source virtualenvwrapper.sh
# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'
# Node / NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"  # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# Set language character set
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"
# Docker w/colima
export DOCKER_HOST="unix://$HOME/.colima/docker.sock"
# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}"
# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'
# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)


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
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Custom Aliases
# source ~/.custom/init.sh

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari SystemUIServer Terminal" killall;


# FZF
eval "$(fzf --bash)"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash


# Universal environment activation hooks NPM and Python
# If .nvmrc is present, use nvm | If .venv is present, use workon
# Example of .nvmrc content:
#   22.18.0
# Example of .venv content (must exist):
#   ultimate-scraper
cd() {
  builtin cd "$@"
  if [ -f .nvmrc ]; then
    nvm use
  fi
  if [ -f .venv ]; then
    workon $(cat .venv)
  fi
}
