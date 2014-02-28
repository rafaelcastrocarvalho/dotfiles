"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set number      "add line numbers
set showbreak=...
set wrap linebreak nolist

"turn off needless toolbar on gvim/mvim
set guioptions-=T


"indent settings
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~,*.class,*/target/* "stuff to ignore when tab completing


"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"necessary on some Linux distros for pathogen to properly load bundles
filetype off

"load pathogen managed plugins
call pathogen#runtime_append_all_bundles()

"turn on syntax highlighting
syntax on

"allow unsaved buffers to become hiden
set hidden

"jump to the window if a buffer is already opened in one
set switchbuf=useopen

"Toggles NERDTree
nmap <silent> <Leader>p :NERDTreeToggle<CR>

" List chars
set list
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the left of the screen

"remove trailing spaces when saving
autocmd BufWritePre * :%s/\s\+$//e


if has("gui")
    "tell the term has 256 colors
    set t_Co=256

    if has("gui_gnome")
        set term=gnome-256color
        colorscheme jellybeans
    else
        set term=xterm-256color
        set guitablabel=%M%t
        colorscheme jellybeans
    endif
    if has("gui_mac") || has("gui_macvim")
        set guifont=Menlo:h14
        " make Mac's Option key behave as the Meta key
        set invmmta
    endif
    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h12
        set enc=utf-8
    endif
else
    "dont load csapprox if there is no gui support - silences an annoying warning
    let g:CSApprox_loaded = 1
endif
