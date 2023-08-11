# 1. Adicionar chaves pública e privada em ~/.ssh

CURRENT_DIR="$(pwd)"
CURRENT_SO="archlinux"

source ./$CURRENT_SO/setup.sh

# Git
git config --global user.name "Rafael Carvalho"                                   && \
git config --global user.email "rafael.c.carvalho@gmail.com.br"                   && \
git config --global core.editor nvim                                              && \
git config --global merge.tool vimdiff                                            && \

# Custom configs
if $(ps -p$$ -ocmd= | grep -q 'bash'); then
  ln -sf $CURRENT_DIR/inputrc ~/.inputrc
else
  echo 'bindkey -v' >> ~/.zshrc
fi

ln -sf $CURRENT_DIR/tmux.conf ~/.tmux.conf                                        && \
ln -sf -T $CURRENT_DIR/vim ~/.vim                                                 && \

git submodule init && git submodule update                                        && \
nvim +PluginInstall +qall                                                         && \

git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d                        && \
ln -sf "$CURRENT_DIR/spacemacs-v26.3" ~/.spacemacs                                && \

echo "legacy_version_file = yes" > ~/.asdfrc                                      && \
echo "source $CURRENT_DIR/bashrc" >> ~/.bashrc
