# Include Locaweb specific bash configurations

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
. $CURRENT_DIR/locaweb/bashrc
. $CURRENT_DIR/aliases.sh


# Make general bash configurations

export EDITOR='vim'

## bash-prompt appearance
txtylw='\033[1;33m'   # Yellow
fgcolor="\033[0m"     # unsets color to term's fg color
arrow=$'\xe2\x86\x92'

### general bash-prompt appearance
export PS1="\w\[$txtylw\] \n$arrow \[$fgcolor\]"

### inside git project bash-prompt appearance
GIT_PROMPT_ONLY_IN_REPO=1
GIT_PROMPT_END="\[$txtylw\] \n$arrow \[$fgcolor\]"
source ~/.bash-git-prompt/gitprompt.sh

## Arch
export VISUAL="vim"

source /usr/share/git/completion/git-prompt.sh
source /usr/share/git/completion/git-completion.bash

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash

#MAC

##Configuring chruby
#source /usr/local/opt/chruby/share/chruby/chruby.sh
#source /usr/local/opt/chruby/share/chruby/auto.sh
#chruby ruby 2.4

#export ACKRC=".ackrc"

#if [ -f $(brew --prefix)/etc/bash_completion ]; then
#  . $(brew --prefix)/etc/bash_completion
#fi

