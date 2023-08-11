echo "Running setup for Archlinux installation"

# Arch packages
# Before all, install sudo as root: pacman -S sudo

sudo pacman -S --needed base-devel neovim git fzf tmux emacs docker postgresql       \
                        jq bash-completion                                        && \

git clone https://aur.archlinux.org/paru.git ~/dev/open-source/paru               && \
cd ~/dev/open-source/paru && makepkg -si                                          && \
paru -S --needed asdf-vm                                                          && \
