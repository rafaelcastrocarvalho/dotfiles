filetype off    "required by vundle

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'CSApprox'
Plugin 'vim-scripts/AutoTag'
"Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'
"Plugin 'derekwyatt/vim-scala'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'rking/ag.vim'
"Plugin 'mileszs/ack.vim'
Plugin 'bling/vim-airline'
Plugin 'junegunn/fzf.vim'
Plugin 'iamcco/markdown-preview.nvim'
Plugin 'elixir-editors/vim-elixir'
Plugin 'vim-terraform'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
