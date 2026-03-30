# Source rc as well for non login shells
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# MOTD banner (shared with zsh)
if [ -f ~/.zlogin ]; then
	. ~/.zlogin
fi