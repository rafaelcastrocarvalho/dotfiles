## Archlinux desktop setup

CURRENT_DIR="$(pwd)"

## Arch packages
# Before all, install sudo as root: pacman -S sudo
sudo pacman -Sy --needed base-devel vim git fzf tmux emacs docker postgresql jq && \
yay -Sy --needed asdf-vm                                                        && \
## Git
git config --global user.name "Rafael Carvalho"                                 && \
git config --global user.email "rafael.carvalho@locaweb.com.br"                 && \
git config --global core.editor vim                                             && \
git config --global merge.tool vimdiff                                          && \
## Custom configs
ln -sf $CURRENT_DIR/inputrc ~/.inputrc                                          && \
ln -sf $CURRENT_DIR/tmux.conf ~/.tmux.conf                                      && \
ln -sf -T $CURRENT_DIR/vim ~/.vim                                               && \
git submodule init && git submodule update                                      && \
vim +PluginInstall +qall                                                        && \
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d                      && \
ln -sf "$CURRENT_DIR/spacemacs-v26.3" ~/.spacemacs                              && \
echo "legacy_version_file = yes" > ~/.asdfrc                                    && \
echo "source $CURRENT_DIR/bashrc" >> ~/.bashrc

