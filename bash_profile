# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source ~/.bash/aliases
source ~/.bash/completions
source ~/.bash/paths
source ~/.bash/configs

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

export TERM=xterm-color
export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'
