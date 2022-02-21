" To turn off error beeping and flashing in Vim, do this:
set visualbell
set t_vb=
" Lets you change buffers without saving them
set hidden

if executable('rg')
  set grepprg=rg\ --vimgrep\ --color=never\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

augroup turnOffBells
  autocmd VimEnter * set vb t_vb=
augroup END

"============================================================================
" Improve startup source: https://github.com/neovim/neovim/issues/2437#issuecomment-522236703
"============================================================================
let g:python_host_prog  = '/python310/python'
let g:python3_host_prog = '/python310/python'

"============================================================================
" Powershell core shell
"============================================================================
let &shell = 'pwsh'
let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
set shellquote= shellxquote=

"============================================================================
" Set encoding.
"============================================================================

set encoding=utf-8
set fileencoding=utf-8

"============================================================================
" spellcheck when writing commit messages
"============================================================================
augroup gitSettings
  autocmd FileType gitcommit setlocal spell
augroup END

"============================================================================
" Set leader key
"============================================================================

let g:mapleader = ' '
let g:maplocalleader = ' '


"============================================================================
" Show File explorer
"============================================================================

let g:netrw_liststyle = 30
let g:netrw_liststyle = 0
nnoremap <Leader>fe :10 Lexplore<CR>

"============================================================================
" Set runtimepath
"============================================================================

set runtimepath+=~/.vim

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
" Complete words from the spelling dict.
set dictionary=spell

"============================================================================
" Make Y behave as D, C
"============================================================================

map Y y$ " Fix for legacy vi inconsistency

"============================================================================
" Move by line on the screen rather than by line in the file
"============================================================================

nnoremap j gj
nnoremap k gk

"============================================================================
" Vimrc
"============================================================================

nnoremap <silent> <leader>ev :e $HOME/.vimrc<CR>
nnoremap <silent> <leader>sv :so $HOME/.vimrc<CR>
nnoremap <leader>ev :vsplit $HOME/.vimrc<CR>

"============================================================================
" Menu completion
"============================================================================

" Don't autocomplete these file types
set suffixes+=.dll,.vs
" Enhanced ex command completion
set wildmenu
" Helps wildmenu auto-completion
set wildmode=longest:full,list:full
" NodeJS dependencies
set wildignore+=*/node_modules/**
" .NET build results
set wildignore+=*/bin/**
set wildignore+=*/obj/**

"============================================================================
" Indent Settings
"============================================================================

" Copy the previous indentation on auto indenting
set copyindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
" Use multiple of shift width when indenting with '<' and '>'
set shiftround

"============================================================================
" Line Settings
"============================================================================

" Enable line numbers
set number
" Changes the line number where the cursor are to zero
"set relativenumber
" Don't wrap lines
set nowrap
" Wont highlight current line
set nocursorline
" Wont make cursor to column
set nocursorcolumn
set scrolloff=5

"============================================================================
" Search Settings
"============================================================================

" Set show matching parenthesis
set showmatch
" Ignore case when searching
set ignorecase
" Ignore case if search pattern is all lowercase, case-sensitive otherwise
set smartcase
" Highlight search terms
set hlsearch
" Show search matches as you type
set incsearch
" Will not redraw the screen while running macros (goes faster)
set lazyredraw

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start
" Add newline to end of file every time you save the file.
set endofline
" Change the terminal's title
set title
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
" Show where you are in file
set ruler
" Add an extra matchpair
set matchpairs+=<:>
" Adds a dollarsign where the change option is applied
set cpoptions+=$
" Highlight the current line and column
" Don't do this - It makes window redraws painfully slow
" Show the current mode
set showmode
" Hide the mouse pointer while typing
set mousehide
filetype on
filetype plugin on
filetype indent on

"============================================================================
" Get xml syntax when editing .NET project & configuration files
"============================================================================

autocmd BufNewFile,BufRead *.fsproj setfiletype xml
autocmd BufNewFile,BufRead *.csproj setfiletype xml
autocmd BufNewFile,BufRead web.config setfiletype xml

"============================================================================
" Spell stuff
"============================================================================

" If you enable set spell the completion will be used. Example :set spell
" spelllang=sv,en
"============================================================================
" Disable unsafe commands.
" http://andrew.stwrt.ca/posts/project-specific-vimrc/
set secure
" Enable word completion for dictionary
set complete+=kspell

"============================================================================
" Load plugins & plugin settings
"============================================================================

if filereadable($HOME . './.vimrc.plugins')
  source $HOME/.vimrc.plugins
endif

"============================================================================
" Save as super user
"============================================================================

cmap w!! w !sudo tee > /dev/null %

"============================================================================
" Good Sources
"============================================================================

" https://github.com/whiteinge/dotfiles
" https://github.com/christoomey/dotfiles
"



"============================================================================
" TODO put in seperate file
"============================================================================
" Plug {
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

  call plug#begin()
  Plug 'morhetz/gruvbox' 
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'dense-analysis/ale'
  Plug 'kyazdani42/nvim-web-devicons' " for file icons
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'honza/vim-snippets'
  Plug 'OmniSharp/omnisharp-vim'
  Plug 'puremourning/vimspector'
  call plug#end()
"}

" omnisharp {
  " Don't autoselect first omnicomplete option, show options even if there is only
  " one (so the preview documentation is accessible). Remove 'preview', 'popup'
  " and 'popuphidden' if you don't want to see any documentation whatsoever.
  " Note that neovim does not support `popuphidden` or `popup` yet:
  " https://github.com/neovim/neovim/issues/10996
  if has('patch-8.1.1880')
    set completeopt=longest,menuone,popuphidden
    " Highlight the completion documentation popup background/foreground the same as
    " the completion menu itself, for better readability with highlighted
    " documentation.
    set completepopup=highlight:Pmenu,border:off
  else
    set completeopt=longest,menuone,preview
    " Set desired preview window height for viewing documentation.
    set previewheight=5
  endif

  let g:OmniSharp_selector_findusages = 'fzf'


  augroup omnisharp_commands
    autocmd!
    " Show type information automatically when the cursor stops moving.
    " Note that the type is echoed to the Vim command line, and will overwrite
    " any other messages in this space including e.g. ALE linting messages.
    autocmd CursorHold *.cs OmniSharpTypeLookup

    " The following commands are contextual, based on the cursor position.
    autocmd FileType cs nmap <silent> <buffer> <Leader>gd <Plug>(omnisharp_go_to_definition)
    autocmd FileType cs nmap <silent> <buffer> <Leader>gi <Plug>(omnisharp_find_implementations)

    autocmd FileType cs nmap <silent> <buffer> <Leader>pd <Plug>(omnisharp_preview_definition)
    autocmd FileType cs nmap <silent> <buffer> <Leader>pi <Plug>(omnisharp_preview_implementations)

    autocmd FileType cs nmap <silent> <buffer> <Leader>fu <Plug>(omnisharp_find_usages)
    autocmd FileType cs nmap <silent> <buffer> <Leader>? <Plug>(omnisharp_documentation)
    autocmd FileType cs nmap <silent> <buffer> <Leader>gm <Plug>(omnisharp_find_symbol)
    autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
    autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)

    " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
    autocmd FileType cs nmap <silent> <buffer> <A-CR> <Plug>(omnisharp_code_actions)
    autocmd FileType cs xmap <silent> <buffer> <A-CR> <Plug>(omnisharp_code_actions)

    " Navigate up and down by method/property/field
    autocmd FileType cs nmap <silent> <buffer> <C-k> <Plug>(omnisharp_navigate_up)
    autocmd FileType cs nmap <silent> <buffer> <C-j> <Plug>(omnisharp_navigate_down)

    " Find all code errors/warnings for the current solution and populate the quickfix window
    autocmd FileType cs nmap <silent> <buffer> <Leader>osgcc <Plug>(omnisharp_global_code_check)

    " Repeat the last code action performed (does not use a selector)
    autocmd FileType cs nmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
    autocmd FileType cs xmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)

    autocmd FileType cs nmap <silent> <buffer> <Leader>rc <Plug>(omnisharp_code_format)

    autocmd FileType cs nmap <silent> <buffer> <F2> <Plug>(omnisharp_rename)
    autocmd FileType cs imap <silent> <buffer> <F2> <C-o>:OmniSharpRename<cr>
  augroup END
"C# }
" ALE {
  let g:ale_linters = {
  \ 'cs': ['OmniSharp'],
  \ 'yaml.cloudformation': ['cfn-lint']
  \}
" }
" coc {
  " Use <c-space> to trigger completion.
  if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
  else
    inoremap <silent><expr> <c-@> coc#refresh()
  endif
" }
" coc-snippets {
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? coc#_select_confirm() :
        \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  let g:coc_snippet_next = '<tab>'

  let g:coc_global_extensions=[ 'coc-powershell', 'coc-snippets' ]
" }

" vimspector {
  nmap <F5> <Plug>VimspectorContinue
  nmap <Leader>bp <Plug>VimspectorToggleBreakpoint
  nmap <F10> <Plug>VimspectorStepOver
  nmap <F11> <Plug>VimspectorStepInto
  nmap <S-F11> <Plug>VimspectorStepOut
" }

" fzf {
  " Disable Preview window
  autocmd VimEnter * command! -bang -nargs=? Files call fzf#vim#files(<q-args>, {'options': '--no-preview'}, <bang>0)
  nnoremap <Leader>ff :Files<CR>
  " Disable Preview window
  autocmd VimEnter * command! -bang -nargs=? GFiles call fzf#vim#gitfiles(<q-args>, {'options': '--no-preview'}, <bang>0)
  nnoremap <Leader>gf :GFiles<CR>
  nnoremap <Leader>/ :Rg<CR>
" }

" colorscheme gruvbox {
  autocmd vimenter * ++nested colorscheme gruvbox
  set termguicolors 
" }

" TODO put in C:\Users\roban2\AppData\Local\nvim\ginit.vim
" GUI logic{
  "Guifont CaskaydiaCove NF:H12:l
"}
