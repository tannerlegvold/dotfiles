# This is a good resource for my Kettelstassen, its how to manage all
# your dotfiles in one place https://dotfiles.github.io/

# Consider adding an alias for sci hub downloads from the command line
# https://sci-hub.se/
# On the same topic as sci hub. https:a# This is a good resource for my Kettelstassen, its how to manage all
# your dotfiles in one place https://dotfiles.github.io/

# Consider adding an alias for sci hub downloads from the command line
# https://sci-hub.se/
# On the same topic as sci hub. https://gist.github.com/bishboria/8326b17bbd652f34566a
# has links to tons of useful math textbooks, but you can no longer get them
# for free. I bet many of them are on Library Genesis though

# For ble.sh
# I have moved the executable to the hidden directory .ble
# So that is doesn't take up space in the ~ directory
# So this code is slightly different from the code on the Github page
[[ $- == *i* ]] && source $HOME/.local/share/blesh/ble.sh --noattach
# It might be possible to get similar functionality out of zsh using
# https://stackoverflow.com/questions/5407916/zsh-zle-shift-selection

# For the FullProf crystallography tool
FULLPROF=/usr/local/bin/FullProf_Suite
PATH=$FULLPROF:$PATH
export FULLPROF

# Put my scripts directory on the $PATH
export PATH="$HOME/scripts:$PATH"

# For some reason the npm executables arn't on my path. It looks like
# this fixes the issue (hopefully)
export PATH="$HOME/.npm-global/bin:$PATH"

# Cabal installs user local executables to here
export PATH="$HOME/.cabal/bin:$PATH"

# This is my default editor
export EDITOR=micro
export VISUAL=micro

# This is a small wrapper around ranger that puts me in the last 
# directory ranger was in when it closed. This works without me having
# to edit ranger's configs at all. Basically its ranger but more convienent
function ranger_cd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

# This binds Ctrl-O to ranger_cd
[[ $- == *i* ]] && bind '"\C-o":"ranger_cd\C-m"'
# The [[ $- == *i* ]] && is so that it only runs in interactive shells. If I 
# don't add this I get errors on login. I got that from https://unix.stackexchange.com/questions/26676/how-to-check-if-a-shell-is-login-interactive-batch
 
# This is so that the ranger command will actually call the ranger_cd command
# alias ranger="ranger_cd"

# Use this to start an app or something from the terminal and have it
# remain open after the terminal closes
function go() {
	setsid --fork "$@" &> /dev/null
}

# Everything above this line was added by me

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

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
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# Everything below this line was added by me

# The alert command given above sends a desktop noftification
# I prefer a sound, this command does that
alias sound="paplay /usr/share/sounds/sound-icons/cembalo-6.wav; paplay /usr/share/sounds/sound-icons/cembalo-6.wav"
# an alternative
# alias sound="paplay /usr/share/sounds/freedesktop/stereo/complete.oga; paplay /usr/share/sounds/freedesktop/stereo/complete.oga; paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
# could also use a phone call sound if you wanted
# alias sound="paplay /usr/share/sounds/freedesktop/stereo/phone-incoming-call.oga"
# This had good instructions for playing sounds from the terminal
# https://askubuntu.com/questions/277215/how-to-make-a-sound-once-a-process-is-complete

# This "dissolves" a directory (moves all its contents into the 
# outer directory, then deletes the now empty directory) the command 
# fails if a name is already taken, which is IMO the right behavior
function dissolve(){
        cd $1
        mv -n {./*,./.*} ..
        cd ..
        rmdir $1
}

# A universal file archive extraction mechanism (supposedly) taken from 
# here: https://wiki.archlinux.org/index.php/Bash/Functions
# There are also various SE and SO posts on the topic...
function extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *.zst) c=(unzstd);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

alias open='xdg-open'

# Adding Mathematica executables to the PATH
export PATH="/usr/local/Wolfram/Mathematica/12.1/Executables:$PATH"

# Settings for oh-my-bash. 

# To see a full list of what can go here thanks to oh-my-bash, 
# see: $OSH/templates/bashrc.osh-templates

export OSH=$HOME/.oh-my-bash

OSH_THEME="agnoster"

completions=(
  git
  composer
  ssh
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
)

# For some reason this line threw a unrecognized CSI sequence: ESC [ D
# error. So I am sending its stderr to /dev/null because i don't 
# want to the see the error on my screen
source $OSH/oh-my-bash.sh 2> /dev/null

# For adding coloring to the man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# This is so directories to which other users can write don't have ugly 
# highlighting and instead look the same as normal directories
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Function to find any package manually installed with 'apt install' by greping dpkg log files
# Taken from: https://askubuntu.com/questions/21657/how-do-i-show-apt-get-package-management-history-via-command-line?noredirect=1&lq=1 
# Usage: apt-history install
# Now if only I could get an equivalent for snap, or, even better, 
# some solution which covers both
function apt-history(){

      case "$1" in
        install)
              grep 'install ' /var/log/dpkg.log
              ;;
        upgrade|remove)
              grep $1 /var/log/dpkg.log
              ;;
        rollback)
              grep upgrade /var/log/dpkg.log | \
                  grep "$2" -A10000000 | \
                  grep "$3" -B10000000 | \
                  awk '{print $4"="$5}'
              ;;
        *)
              cat /var/log/dpkg.log
              ;;
      esac
}

# For ble.sh
((_ble_bash)) && ble-attach

//gist.github.com/bishboria/8326b17bbd652f34566a
# has links to tons of useful math textbooks, but you can no longer get them
# for free. I bet many of them are on Library Genesis though

# For ble.sh
# I have moved the executable to the hidden directory .ble
# So that is doesn't take up space in the ~ directory
# So this code is slightly different from the code on the Github page
[[ $- == *i* ]] && source $HOME/.local/share/blesh/ble.sh --noattach
# It might be possible to get similar functionality out of zsh using
# https://stackoverflow.com/questions/5407916/zsh-zle-shift-selection

# For the FullProf crystallography tool
FULLPROF=/usr/local/bin/FullProf_Suite
PATH=$FULLPROF:$PATH
export FULLPROF

# For some reason the npm executables arn't on my path. It looks like
# this fixes the issue (hopefully)
export PATH="$HOME/.npm-global/bin:$PATH"

# Cabal installs user local executables to here
export PATH="$HOME/.cabal/bin:$PATH"

# This is my default editor
export EDITOR=micro
export VISUAL=micro

# This is a small wrapper around ranger that puts me in the last 
# directory ranger was in when it closed. This works without me having
# to edit ranger's configs at all. Basically its ranger but more convienent
function ranger_cd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

# This binds Ctrl-O to ranger_cd
[[ $- == *i* ]] && bind '"\C-o":"ranger_cd\C-m"'
# The [[ $- == *i* ]] && is so that it only runs in interactive shells. If I 
# don't add this I get errors on login. I got that from https://unix.stackexchange.com/questions/26676/how-to-check-if-a-shell-is-login-interactive-batch
 
# This is so that the ranger command will actually call the ranger_cd command
# alias ranger="ranger_cd"

# Use this to start an app or something from the terminal and have it
# remain open after the terminal closes
function go() {
	setsid --fork "$@" &> /dev/null
}

# Everything above this line was added by me

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

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
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# Everything below this line was added by me

# The alert command given above sends a desktop noftification
# I prefer a sound, this command does that
alias sound="paplay /usr/share/sounds/sound-icons/cembalo-6.wav; paplay /usr/share/sounds/sound-icons/cembalo-6.wav"
# an alternative
# alias sound="paplay /usr/share/sounds/freedesktop/stereo/complete.oga; paplay /usr/share/sounds/freedesktop/stereo/complete.oga; paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
# could also use a phone call sound if you wanted
# alias sound="paplay /usr/share/sounds/freedesktop/stereo/phone-incoming-call.oga"
# This had good instructions for playing sounds from the terminal
# https://askubuntu.com/questions/277215/how-to-make-a-sound-once-a-process-is-complete

# This "dissolves" a directory (moves all its contents into the 
# outer directory, then deletes the now empty directory) the command 
# fails if a name is already taken, which is IMO the right behavior
function dissolve(){
        cd $1
        mv -n {./*,./.*} ..
        cd ..
        rmdir $1
}

# A universal file archive extraction mechanism (supposedly) taken from 
# here: https://wiki.archlinux.org/index.php/Bash/Functions
# There are also various SE and SO posts on the topic...
function extract() {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *.zst) c=(unzstd);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}

alias open='xdg-open'

# Adding Mathematica executables to the PATH
export PATH="/usr/local/Wolfram/Mathematica/12.1/Executables:$PATH"

# Settings for oh-my-bash. 

# To see a full list of what can go here thanks to oh-my-bash, 
# see: $OSH/templates/bashrc.osh-templates

export OSH=$HOME/.oh-my-bash

OSH_THEME="agnoster"

completions=(
  git
  composer
  ssh
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
)

# For some reason this line threw a unrecognized CSI sequence: ESC [ D
# error. So I am sending its stderr to /dev/null because i don't 
# want to the see the error on my screen
source $OSH/oh-my-bash.sh 2> /dev/null

# For adding coloring to the man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# This is so directories to which other users can write don't have ugly 
# highlighting and instead look the same as normal directories
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Function to find any package manually installed with 'apt install' by greping dpkg log files
# Taken from: https://askubuntu.com/questions/21657/how-do-i-show-apt-get-package-management-history-via-command-line?noredirect=1&lq=1 
# Usage: apt-history install
# Now if only I could get an equivalent for snap, or, even better, 
# some solution which covers both
function apt-history(){

      case "$1" in
        install)
              grep 'install ' /var/log/dpkg.log
              ;;
        upgrade|remove)
              grep $1 /var/log/dpkg.log
              ;;
        rollback)
              grep upgrade /var/log/dpkg.log | \
                  grep "$2" -A10000000 | \
                  grep "$3" -B10000000 | \
                  awk '{print $4"="$5}'
              ;;
        *)
              cat /var/log/dpkg.log
              ;;
      esac
}

# For ble.sh
((_ble_bash)) && ble-attach

