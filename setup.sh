# 1. Adicionar chaves pública e privada em ~/.ssh

CURRENT_DIR="$(pwd)"
CURRENT_SO="archlinux"

source ./$CURRENT_SO/setup.sh

# Git
git config --global user.name "Rafael Carvalho"                                   && \
git config --global user.email "rafael.c.carvalho@gmail.com"                      && \
git config --global core.editor nvim                                              && \
git config --global merge.tool nvimdiff                                           && \

# Custom configs
if $(ps -p$$ -ocmd= | grep -q 'bash'); then
  ln -sf $CURRENT_DIR/inputrc ~/.inputrc
else
  echo 'bindkey -v' >> ~/.zshrc
fi

ln -sf $CURRENT_DIR/tmux.conf ~/.tmux.conf                                        && \
echo "legacy_version_file = yes" > ~/.asdfrc                                      && \
echo "source $CURRENT_DIR/bashrc" >> ~/.bashrc
