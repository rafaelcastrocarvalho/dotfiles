alias docker-rm='docker rm -f $(docker ps -aq)'
alias docker-rmi='docker rmi -f $(docker images -q)'
alias docker-clear='docker-rm; docker-rmi'
