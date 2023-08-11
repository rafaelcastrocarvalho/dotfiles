filetype off    "required by vundle

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'
Plugin 'CSApprox'
"Plugin 'ctrlpvim/ctrlp.vim'
"Plugin 'derekwyatt/vim-scala'
Plugin 'elixir-editors/vim-elixir'
Plugin 'iamcco/markdown-preview.nvim'
Plugin 'junegunn/fzf.vim'
"Plugin 'mileszs/ack.vim'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rails'
Plugin 'vim-ruby/vim-ruby'
Plugin 'vim-scripts/AutoTag'
Plugin 'vim-terraform'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
