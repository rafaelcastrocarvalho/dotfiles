CURRENT_DIR="$(pwd)"

git config --global user.name "Rafael Carvalho"                  && \
git config --global user.email "rafael.carvalho@locaweb.com.br"  && \
git config --global core.editor vim                              && \
git config --global merge.tool vimdiff                           && \

ln -sf $CURRENT_DIR/tmux.conf ~/.tmux.conf && \
ln -sf -T $CURRENT_DIR/vim ~/.vim          && \
git submodule init && git submodule update && \
vim +PluginInstall +qall                   && \
echo "source $CURRENT_DIR/bashrc" >> ~/.bashrc


