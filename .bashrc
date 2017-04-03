#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'
# ^^^ unofficial bash mode: https://perma.cc/UQ45-72E5

export TERM="screen-256color"
export EDITOR='nvim'
# export PAGER=most
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
set +o vi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# ========================================================= #
# history and autofill                                      #
# ========================================================= #
# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
    xterm)
      export TERM="xterm-256color"
      color_prompt=yes;;
    screen)
      export TERM="screen-256color"
      color_prompt=yes;;
esac

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoredups:ignorespace:erasedups:ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# shopt -s histappend     # append to the history file, don't overwrite it
shopt -s nocaseglob     # auto corrects the case
# shopt -s checkwinsize   # check the window size after each command and, if
                        # necessary, update the values of LINES and COLUMNS.

# bash automatically fetches the last command that starts with the
# given term: E.G. you type in ‘ssh’ and press the ‘Page Up’ key and bash
# scrolls through your history for this. Store function in .inputrc
export INPUTRC=$HOME/.inputrc

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ========================================================= #
# ls config                                                 #
# ========================================================= #
# some ls aliases
alias tree='tree -C'
alias ls='ls -G'

# Relative Jumps:
alias ~='cd ~ '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ========================================================= #
# initialization scripts which are auto-generated           #
# ========================================================= #
# disabling for speed - you might have to run these on startx
# alias start_irssi='bitlebee -F -u stites && irssi'
# alias r='grunt'

#export NODE_PATH=/usr/local/lib/node:/usr/local/lib/node_modules:$HOME/.nvm/v0.10.32/lib/node_modules

# ===================== #
# .bashrc functions     #
# ===================== #
alias vrc='vim $HOME/.bashrc'
alias src='source $HOME/.bashrc'
# == ghci to bash == #
alias ":q"=exit
alias ":r"=myReload

#=======================#
# Add git-aware prompt  #
#=======================#
# -- primarily cause I'm super lazy: https://github.com/jimeh/git-aware-prompt
export GITAWAREPROMPT=$HOME/.bash/git-aware-prompt
if [ -e $GITAWAREPROMPT ]; then
  source "${GITAWAREPROMPT}/main.sh"
fi

#=======================#
# Use Nix               #
#=======================#
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh;
fi

# ========================================= #
# TODO: load init configs in plist somehow  #
# ========================================= #
[[ ! -f ~/git/configs/init.d/load_env  ]] || source ~/git/configs/init.d/load_env

# ========================================= #
# Load the remaining settings               #
# ========================================= #

for SETTING in git tmux npm task nginx vim python hesse ruby; do
  [[ ! -f $HOME/.bashrc_$SETTING  ]] || source $HOME/.bashrc_$SETTING
done

[[ ! -f $HOME/.bash-wakatime/bash-wakatime.sh  ]] || source $HOME/.bash-wakatime/bash-wakatime.sh

# add stack installs to path
safe_path_add $HOME/.local/bin/

# stack autocomplete
eval "$(stack --bash-completion-script stack)"

# ========================================= #
# write a note                              #
# ========================================= #
function stacknew {
  stack new $1 --bare ~/git/stack-templates/skeleton
}

alias ag='ag --path-to-agignore ~/.agignore'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r $HOME/.dircolors && eval "$(dircolors -b $HOME/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
