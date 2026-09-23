# Aliases shared by bash and zsh.

alias docker-rm='docker rm -f $(docker ps -aq)'
alias docker-rmi='docker rmi -f $(docker images -q)'
alias docker-clear='docker-rm; docker-rmi'

alias glog="git log --graph --pretty=format:'%C(yellow)%h%Creset -%Cred%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Alternate Neovim configs, kept side by side via NVIM_APPNAME.
alias nvim-astro='NVIM_APPNAME=nvim-astro nvim'
alias nvim-lazy='NVIM_APPNAME=nvim-lazy nvim'
