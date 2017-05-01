"============================================================================
" spellcheck when writing commit logs
"============================================================================
autocmd filetype svn,*commit* setlocal spell
"============================================================================
" Set leader key
"============================================================================
let mapleader=" "
let maplocalleader=" "
"============================================================================
" Set runetimepath
"============================================================================
set rtp+=~/.vim
"============================================================================
" Perform recursive search when using find command.
"============================================================================
set path+=**
"============================================================================
" Paste last yanked item
"============================================================================
noremap <Leader>p "0p
noremap <Leader>P "0P
"============================================================================
" Quote Selection
"============================================================================
vnoremap <Leader>" c"<C-r>""<Esc>
"============================================================================
" Enter normal mode from insert mode
"============================================================================
inoremap jk <esc>
"============================================================================
" Make Y behave as D, C
"============================================================================
map Y y
noremap Y y$
"============================================================================
" Move by line on the screen rather than by line in the file
"============================================================================
nnoremap j gj
nnoremap k gk
"============================================================================
nmap <silent>  <BS>  :nohlsearch<CR>
"============================================================================
" Cycle through history in Command-Line Window
"============================================================================
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
"============================================================================
" Use arrow keys to navigate after a :vimgrep or :helpgrep
"============================================================================
nmap <silent> <RIGHT>         :cnext<CR>
nmap <silent> <RIGHT><RIGHT>  :cnfile<CR><C-G>
nmap <silent> <LEFT>          :cprev<CR>
nmap <silent> <LEFT><LEFT>    :cpfile<CR><C-G>
"============================================================================
" Navigate buffer list
"============================================================================
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>
"============================================================================
" Vimrc
"============================================================================
nmap <silent> <leader>ev :e $HOME/.vimrc<CR>
nmap <silent> <leader>sv :so $HOME/.vimrc<CR>
nnoremap <leader>ev :vsplit $HOME/.vimrc<CR>
"============================================================================
" Abberviations
"============================================================================
" Make :help appear in a full-screen tab, instead of a window
"============================================================================
augroup HelpInTabs
  autocmd!
  autocmd BufEnter  *.txt   call HelpInNewTab()
augroup END

function! HelpInNewTab ()
  if &buftype == 'help'
    execute "normal \<C-W>T"
  endif
endfunction
"============================================================================
" When completing, show all options, insert common prefix, then iterate
"============================================================================
set wildmenu
set wildmode=longest:full,full
"============================================================================
" Indent Settings
"============================================================================
set copyindent    " Copy the previous indentation on autoindenting
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set shiftround    " Use multiple of shiftwidth when indenting with '<' and '>'
"============================================================================
" Line Settings
"============================================================================
set number          " Enable line numbers
set relativenumber  " Changes the line number where the cursor are to zero
set nowrap          " Don't wrap lines
set nocursorline    " Wont higlight current line
set nocursorcolumn  " Wont make cursor to column
set scrolloff=5
"============================================================================
" Search Settings
"============================================================================
set showmatch     " Set show matching parenthesis
set ignorecase    " Ignore case when searching
set smartcase     " Ignore case if search pattern is all lowercase, case-sensitive otherwise
set hlsearch      " Highlight search terms
set incsearch     " Show search matches as you type
"============================================================================
" For virtual lines, helps when text is wrapped
" nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
" nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
" set nrformats=alpha " Set increment numbers in decimal
"============================================================================
set backspace=indent,eol,start " Allow backspacing over everything in insert mode
set eol " Add newline to end of file everytime you save the file.
set title                " Change the terminal's title
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set ruler        " Show where you are in file
set matchpairs+=<:> " Add an extra matchpair
set cpoptions+=$ " Adds a dollarsign where the change option is applied
" Highlight the current line and column
" Don't do this - It makes window redraws painfully slow
" Show the current mode
set showmode
set mousehide " Hide the mouse pointer while typing
filetype on
filetype plugin on
filetype indent on
" Shrink the current window to fit the number of lines in the buffer.  Useful
" For those buffers that are only a few lines
nmap <silent> <leader>sw :execute ":resize " . line('$')<cr>
"============================================================================
" .NET Core
"============================================================================
autocmd FileType cs nmap <leader>R :!dotnet run<CR>
autocmd FileType cs nmap <leader>B :!dotnet build<CR>
autocmd FileType fsharp nmap <leader>R :!dotnet run<CR>
autocmd FileType fsharp nmap <leader>B :!dotnet build<CR>
"============================================================================
" If you enable set spell the completion will be used. Example :set spell
" spelllang=sv,en
"============================================================================
" Disable unsafe commands.
" http://andrew.stwrt.ca/posts/project-specific-vimrc/
set secure
set complete+=kspell " enable word completion for dictionary
"============================================================================
" Load plugins & plugin settings
"============================================================================
source $HOME/.vimrc.plugins
"============================================================================
" Spell stuff
"============================================================================
"Spell files are in GDrive do the following to set it up.
"$ rmdir ~/.vim/spell
"$ ln -s ~/Dropbox/vim/spell ~/.vim/spell
"============================================================================
" To update spell dictionary.
"============================================================================
":edit <spell file>
"(make changes to the spell file)
":mkspell! %
syntax enable
