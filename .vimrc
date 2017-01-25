if &shell =~# 'fish$'
      set shell=sh
   endif
let mapleader=" "
let maplocalleader=" "
call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-easy-align'
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/tpope/vim-dispatch'
Plug 'https://github.com/kien/ctrlp.vim'
Plug 'https://github.com/junegunn/vim-github-dashboard.git'
Plug 'https://github.com/metakirby5/codi.vim'
Plug 'https://github.com/scrooloose/syntastic'
Plug 'https://github.com/Valloric/YouCompleteMe'
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
Plug 'https://github.com/dag/vim-fish'
Plug 'https://github.com/christoomey/vim-tmux-navigator'
Plug 'https://github.com/tmux-plugins/vim-tmux'
Plug 'https://github.com/OmniSharp/omnisharp-vim'
Plug 'https://github.com/SirVer/ultisnips'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'fsharp/vim-fsharp', {
      \ 'for': 'fsharp',
      \ 'do':  'make fsautocomplete',
      \}


" Add plugins to &runtimepath
call plug#end()
set rtp+=~/.vim
set background=dark
if has('nvim')
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
  let g:solarized_italic=0
  au VimEnter * colorscheme solarized
endif
colorscheme solarized
syntax enable
"============================================================================
"Perform recursive search
"============================================================================
set path+=**
"============================================================================
"Paste last yanked item
"============================================================================
noremap <Leader>p "0p
noremap <Leader>P "0P
"============================================================================
"Quote Selection
"============================================================================
vnoremap <Leader>" c"<C-r>""<Esc>
"============================================================================
"Enter normal mode from insert mode
"============================================================================
inoremap jk <esc>
"============================================================================
"Make Y behave as D, C
"============================================================================
map Y y
noremap Y y$
"============================================================================
"Move by line on the screen rather than by line in the file
"============================================================================
nnoremap j gj
nnoremap k gk
"============================================================================
nmap <silent>  <BS>  :nohlsearch<CR>
"============================================================================
"Cycle through history in Command-Line Window
"============================================================================
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
"============================================================================
"Use arrow keys to navigate after a :vimgrep or :helpgrep
"============================================================================
nmap <silent> <RIGHT>         :cnext<CR>
nmap <silent> <RIGHT><RIGHT>  :cnfile<CR><C-G>
nmap <silent> <LEFT>          :cprev<CR>
nmap <silent> <LEFT><LEFT>    :cpfile<CR><C-G>
"============================================================================
"Navigate buffer list
"============================================================================
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>
"============================================================================
"Vimrc
"============================================================================
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
"============================================================================
"Syntastic Settings
"============================================================================
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = 'eslint_d'
let g:processing_doc_style = 'local'
let g:fsharp_completion_helptext = 1

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
"When completing, show all options, insert common prefix, then iterate
"============================================================================
set wildmenu
set wildmode=longest:full,full
"============================================================================
"Indent Settings
"============================================================================
set copyindent    " Copy the previous indentation on autoindenting
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set shiftround    " Use multiple of shiftwidth when indenting with '<' and '>'
"============================================================================
"Line Settings
"============================================================================
set number          " Enable line numbers
set relativenumber  " Changes the line number where the cursor are to zero
set nowrap          " Don't wrap lines
set nocursorline    " Wont higlight current line
set nocursorcolumn  " Wont make cursor to column
set scrolloff=5
"============================================================================
"Search Settings
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
" Hide the mouse pointer while typing
set mousehide
filetype on
filetype plugin on
filetype indent on
" Shrink the current window to fit the number of lines in the buffer.  Useful
" For those buffers that are only a few lines
nmap <silent> <leader>sw :execute ":resize " . line('$')<cr>
"============================================================================
"Dotnet Core
"============================================================================
  "C#
    autocmd FileType cs nmap <leader>R :!dotnet run<CR>
    autocmd FileType cs nmap <leader>B :!dotnet build<CR>
  "F#
    autocmd FileType fsharp nmap <leader>R :!dotnet run<CR>
    autocmd FileType fsharp nmap <leader>B :!dotnet build<CR>
let g:OmniSharp_selector_ui = 'ctrlp'


"This is the default value, setting it isn't actually necessary
let g:OmniSharp_host = "http://localhost:2000"

"Set the type lookup function to use the preview window instead of the status line
"let g:OmniSharp_typeLookupInPreview = 1

"Timeout in seconds to wait for a response from the server
let g:OmniSharp_timeout = 1

"Showmatch significantly slows down omnicomplete
"when the first match contains parentheses.
set noshowmatch

"Super tab settings - uncomment the next 4 lines
"let g:SuperTabDefaultCompletionType = 'context'
"let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"
"let g:SuperTabDefaultCompletionTypeDiscovery = ["&omnifunc:<c-x><c-o>","&completefunc:<c-x><c-n>"]
"let g:SuperTabClosePreviewOnPopupClose = 1

"don't autoselect first item in omnicomplete, show if only one item (for preview)
"remove preview if you don't want to see any documentation whatsoever.
set completeopt=longest,menuone,preview
" Fetch full documentation during omnicomplete requests.
" There is a performance penalty with this (especially on Mono)
" By default, only Type/Method signatures are fetched. Full documentation can still be fetched when
" you need it with the :OmniSharpDocumentation command.
" let g:omnicomplete_fetch_documentation=1

"Move the preview window (code documentation) to the bottom of the screen, so it doesn't move the code!
"You might also want to look at the echodoc plugin
set splitbelow

" Get Code Issues and syntax errors
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']
" If you are using the omnisharp-roslyn backend, use the following
" let g:syntastic_cs_checkers = ['code_checker']
augroup omnisharp_commands
    autocmd!

    "Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

    " Synchronous build (blocks Vim)
    "autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
    " Builds can also run asynchronously with vim-dispatch installed
    autocmd FileType cs nnoremap <leader>b :wa!<cr>:OmniSharpBuildAsync<cr>
    " automatic syntax check on events (TextChanged requires Vim 7.4)
    autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

    " Automatically add new cs files to the nearest project on save
    autocmd BufWritePost *.cs call OmniSharp#AddToProject()

    "show type information automatically when the cursor stops moving
    autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()

    "The following commands are contextual, based on the current cursor position.

    autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
    autocmd FileType cs nnoremap <leader>fi :OmniSharpFindImplementations<cr>
    autocmd FileType cs nnoremap <leader>ft :OmniSharpFindType<cr>
    autocmd FileType cs nnoremap <leader>fs :OmniSharpFindSymbol<cr>
    autocmd FileType cs nnoremap <leader>fu :OmniSharpFindUsages<cr>
    "finds members in the current buffer
    autocmd FileType cs nnoremap <leader>fm :OmniSharpFindMembers<cr>
    " cursor can be anywhere on the line containing an issue
    autocmd FileType cs nnoremap <leader>x  :OmniSharpFixIssue<cr>
    autocmd FileType cs nnoremap <leader>fx :OmniSharpFixUsings<cr>
    autocmd FileType cs nnoremap <leader>tt :OmniSharpTypeLookup<cr>
    autocmd FileType cs nnoremap <leader>dc :OmniSharpDocumentation<cr>
    "navigate up by method/property/field
    autocmd FileType cs nnoremap <C-K> :OmniSharpNavigateUp<cr>
    "navigate down by method/property/field
    autocmd FileType cs nnoremap <C-J> :OmniSharpNavigateDown<cr>

augroup END


" this setting controls how long to wait (in ms) before fetching type / symbol information.
set updatetime=500
" Remove 'Press Enter to continue' message when type information is longer than one line.
set cmdheight=2

" Contextual code actions (requires CtrlP or unite.vim)
nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
" Run code actions with text selected in visual mode to extract method
vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>

" rename with dialog
nnoremap <leader>nm :OmniSharpRename<cr>
nnoremap <F2> :OmniSharpRename<cr>
" rename without dialog - with cursor on the symbol to rename... ':Rename newname'
command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

" Force OmniSharp to reload the solution. Useful when switching branches etc.
nnoremap <leader>rl :OmniSharpReloadSolution<cr>
nnoremap <leader>cf :OmniSharpCodeFormat<cr>
" Load the current .cs file to the nearest project
nnoremap <leader>tp :OmniSharpAddToProject<cr>

" (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
nnoremap <leader>ss :OmniSharpStartServer<cr>
nnoremap <leader>sp :OmniSharpStopServer<cr>

" Add syntax highlighting for types and interfaces
nnoremap <leader>th :OmniSharpHighlightTypes<cr>
"Don't ask to save when changing buffers (i.e. when jumping to a type definition)
set hidden

" Enable snippet completion, requires completeopt-=preview
let g:OmniSharp_want_snippet=1
let g:OmniSharp_server_type = 'roslyn'
