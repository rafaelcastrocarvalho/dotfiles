# 1. Adicionar chaves pública e privada em ~/.ssh

CURRENT_DIR="$(pwd)"

## Arch packages
# Before all, install sudo as root: pacman -S sudo
#sudo pacman -Sy --needed base-devel vim git fzf tmux emacs docker postgresql jq && \
#yay -Sy --needed asdf-vm                                                        && \

## Ubuntu packages
#sudo add-apt-repository ppa:kelleyk/emacs                                       && \
#sudo apt-get install gnome-tweak-tool xcape git vim tmux docker postgresql jq    \
#                     zlib1g-dev build-essential libssl-dev libreadline-dev       \
#                     libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
#                     libffi-dev emacs26                                         && \
#git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf                  && \
#~/.fzf/install                                                                  && \
#git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1           && \

## CapsLock as Ctrl and Esc
#setxkbmap -option 'caps:ctrl_modifier'                                          && \
#xcape -e 'Caps_Lock=Escape'                                                     && \
#setxkbmap -option 'caps:ctrl_modifier'                                          && \
#xcape -e 'Caps_Lock=Escape;Control_L=Escape;Control_R=Escape'                   && \


## Git
#git config --global user.name "Rafael Carvalho"                                 && \
#git config --global user.email "rafael.carvalho@locaweb.com.br"                 && \
#git config --global core.editor vim                                             && \
#git config --global merge.tool vimdiff                                          && \

## Custom configs
#ln -sf $CURRENT_DIR/inputrc ~/.inputrc                                          && \
#ln -sf $CURRENT_DIR/tmux.conf ~/.tmux.conf                                      && \
#ln -sf -T $CURRENT_DIR/vim ~/.vim                                               && \
#git submodule init && git submodule update                                      && \
#vim +PluginInstall +qall                                                        && \
#git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d                      && \
#ln -sf "$CURRENT_DIR/spacemacs-v26.3" ~/.spacemacs                              && \
#echo "legacy_version_file = yes" > ~/.asdfrc                                    && \
#echo "source $CURRENT_DIR/bashrc" >> ~/.bashrc
