let mapleader=" "
set scrolloff=5
"============================================================================
" Bindings
"============================================================================
"	Enter normal mode from insert mode
"============================================================================
		inoremap jk <esc>
"============================================================================
	" Make delete key in Normal mode remove the persistently highlighted matches
"============================================================================
" Make Y behave as D, C
"============================================================================
" This pisses me off so much D is d$ C is c$ A is $a but Y is yy. WHY?
  map Y y
  noremap Y y$
"============================================================================
"	move by line on the screen rather than by line in the file
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
"	VIMRC
"============================================================================
		nmap <silent> <leader>ev :e $MYVIMRC<CR>
		nmap <silent> <leader>sv :so $MYVIMRC<CR>
		nnoremap <leader>ev :vsplit $MYVIMRC<cr>
"============================================================================
"	Open NerdTree
"============================================================================
		nmap <leader>n :NERDTree<CR>
"============================================================================
" Bindings End
"============================================================================
" Abberviations
"============================================================================
  inoreabbrev lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla.<cr><cr>Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor. Morbi lectus risus, iaculis vel, suscipit quis, luctus non, massa. Fusce ac turpis quis ligula lacinia aliquet. Mauris ipsum. Nulla metus metus, ullamcorper vel, tincidunt sed, euismod in, nibh.<cr><cr>Quisque volutpat condimentum velit. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam nec ante. Sed lacinia, urna non tincidunt mattis, tortor neque adipiscing diam, a cursus ipsum ante quis turpis. Nulla facilisi. Ut fringilla. Suspendisse potenti. Nunc feugiat mi a tellus consequat imperdiet. Vestibulum sapien. Proin quam. Etiam ultrices. Suspendisse in justo eu magna luctus suscipit. Sed lectus.
"============================================================================
" Vundle Config
  execute pathogen#infect()
"============================================================================
	set nocompatible              " Be iMproved, required
	filetype off                  " Required
	" Set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'scrooloose/syntastic'
	Plugin 'scrooloose/nerdtree'
	Plugin 'tpope/vim-fugitive'
	"Plugin 'Valloric/YouCompleteMe'
	call vundle#end()            " Required
	filetype plugin indent on    " Required
	syntax on
	syntax enable
	set swapfile
	set dir=~/tmp
	set backupcopy=yes
"============================================================================
" Make :help appear in a full-screen tab, instead of a window
"============================================================================
    " Only apply to .txt files...
    augroup HelpInTabs
        autocmd!
        autocmd BufEnter  *.txt   call HelpInNewTab()
    augroup END

    " Only apply to help files...
    function! HelpInNewTab ()
        if &buftype == 'help'
            " Convert the help window to a tab...
            execute "normal \<C-W>T"
        endif
    endfunction
"============================================================================
" When completing, show all options, insert common prefix, then iterate
"============================================================================
	set wildmenu
	set wildmode=longest:full,full
"============================================================================
" Syntastic Settings
"============================================================================
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*
	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 0
	let g:syntastic_javascript_checkers = ['eslint']
	let g:syntastic_aggregate_errors = 1
"============================================================================
" Indent Settings
"============================================================================
	set copyindent    " Copy the previous indentation on autoindenting
	set smarttab      " Insert tabs on the start of a line according to
	set tabstop=2
	set shiftwidth=2
	set softtabstop=2
	set expandtab
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
