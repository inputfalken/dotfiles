"============================================================================
" Set encoding.
"============================================================================
set encoding=utf-8
set fileencoding=utf-8
"============================================================================
" spellcheck when writing commit messages
"============================================================================
autocmd filetype svn,*commit* setlocal spell
"============================================================================
" Set leader key
"============================================================================
let mapleader=" "
let maplocalleader=" "
"============================================================================
" Set runtimepath
"============================================================================
set rtp+=~/.vim
"============================================================================
" Perform recursive search when using find command.
"============================================================================
set path+=**
"============================================================================
" Paste last yanked item
"============================================================================
noremap <Leader>P "0P
"============================================================================
" Enter normal mode from insert mode
"============================================================================
inoremap jk <esc>
"============================================================================
" Completion
"============================================================================
inoremap <nul> <C-X><C-O> " Maps Omnicompletion to CTRL-space.
inoremap <C-F> <C-X><C-F> " Maps file completion to CTRL-F.
map <leader>fc /\v^[<=>]{7}( .*\|$)<cr> " Find merge conflict markers
set dictionary=spell " Complete words from the spelling dict.
"============================================================================
" Make Y behave as D, C
"============================================================================
nnoremap Y y
noremap Y y$
"============================================================================
" Move by line on the screen rather than by line in the file
"============================================================================
nnoremap j gj
nnoremap k gk
"============================================================================
nnoremap <silent> <RIGHT>         :cnext<CR>
nnoremap <silent> <RIGHT><RIGHT>  :cnfile<CR><C-G>
nnoremap <silent> <LEFT>          :cprev<CR>
nnoremap <silent> <LEFT><LEFT>    :cpfile<CR><C-G>
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
nnoremap <silent> <leader>ev :e $HOME/.vimrc<CR>
nnoremap <silent> <leader>sv :so $HOME/.vimrc<CR>
nnoremap <leader>ev :vsplit $HOME/.vimrc<CR>
"============================================================================
" Menu completion
"============================================================================
set suffixes+=.dll,.vs " Don't autocomplete these filetypes
set wildmenu "wmnu:  enhanced ex command completion
set wildmode=longest:full,list:full "wim:   helps wildmenu auto-completion
set wildignore+=*/node_modules/**
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
set lazyredraw    " Will not redraw the screen while running macros (goes faster)
"============================================================================
" Interactive Powershell
"============================================================================
" Only works on windows.
function! EvaluatePowershellSelection()
  let tempDirectory = $TEMP
  let fileName = "evalPowershell.ps1"
  let filePath = tempDirectory . "\\" . fileName
  silent! execute "'<,'>write! " . filePath
  execute "!powershell " . filePath
endfunction
augroup powershell
  autocmd!
  autocmd FileType ps1 xnoremap <leader>i :<C-W> call EvaluatePowershellSelection()<CR>
  autocmd FileType ps1 set foldmethod=syntax
augroup END

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
"============================================================================
" Spell stuff
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
"Spell files are in GDrive do the following to set it up.
"$ rmdir ~/.vim/spell
"$ ln -s ~/Dropbox/vim/spell ~/.vim/spell
"============================================================================
" To update spell dictionary.
"============================================================================
":edit <spell file>
"(make changes to the spell file)
":mkspell! %
"============================================================================
" Enable syntax highlight if it's possible.
"============================================================================
" The if prevents an unnecessary execution of code
" source: http://stackoverflow.com/a/33380495/5384895
if !exists("g:syntax_on")
  syntax enable
endif
