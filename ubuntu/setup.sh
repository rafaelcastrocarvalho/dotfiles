echo "Running setup for Ubuntu installation"

# Ubuntu packages
sudo add-apt-repository ppa:kelleyk/emacs                                         && \
sudo apt-get install gnome-tweak-tool xcape git vim tmux docker emacs26              \
                     cmake libmysqlclient-dev libpq-dev libpq5 postgresql jq         \
                     zlib1g-dev build-essential libssl-dev libreadline-dev           \
                     libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev     \
                     libffi-dev silversearcher-ag                                 && \
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1             && \
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf                    && \
~/.fzf/install                                                                    && \

# CapsLock as Ctrl and Esc
setxkbmap -option 'caps:ctrl_modifier'                                            && \
xcape -e 'Caps_Lock=Escape'                                                       && \
setxkbmap -option 'caps:ctrl_modifier'                                            && \
xcape -e 'Caps_Lock=Escape;Control_L=Escape;Control_R=Escape'                     && \


