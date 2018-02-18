" To turn off error beeping and flashing in Vim, do this:
set visualbell
set t_vb=
" Lets you change buffers without saving them
set hidden

autocmd GUIEnter * set vb t_vb=
autocmd VimEnter * set vb t_vb=

"============================================================================
" Set encoding.
"============================================================================

set encoding=utf-8
set fileencoding=utf-8

"============================================================================
" spellcheck when writing commit messages
"============================================================================

autocmd filetype svn,*commit* setlocal spell

" Flex Development
autocmd BufNewFile,BufRead *.mxml setfiletype mxml
autocmd BufNewFile,BufRead *.as setfiletype actionscript

" Handle *.csproj, *.fsproj, web.config as xml
autocmd BufNewFile,BufRead *.fsproj setfiletype xml
autocmd BufNewFile,BufRead *.csproj setfiletype xml
autocmd BufNewFile,BufRead web.config setfiletype xml

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
" Find merge conflict markers
map <leader>fc /\v^[<=>]{7}( .*\|$)<cr>
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
"wmnu:  enhanced ex command completion
set wildmenu
"wim:   helps wildmenu auto-completion
set wildmode=longest:full,list:full
set wildignore+=*/node_modules/**

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

"" Enable line numbers
set number
" Changes the line number where the cursor are to zero
set relativenumber
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

"============================================================================
" Interactive PowerShell
"============================================================================

" Only works on windows.
function! EvaluatePowershellSelection()
  let tempDirectory = $TEMP
  let fileName = "evalPowerShell.ps1"
  let filePath = tempDirectory . "\\" . fileName
  silent! execute "'<,'>write! " . filePath
  execute "!PowerShell " . filePath
endfunction
augroup powershell
  autocmd!
  autocmd FileType ps1 xnoremap <leader>i :<C-W> call EvaluatePowershellSelection()<CR>
  autocmd FileType ps1 set foldmethod=syntax
augroup END

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start
" Add newline to end of file every time you save the file.
set eol
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

if filereadable($HOME . "./.vimrc.plugins")
  source $HOME/.vimrc.plugins
endif
"Spell files are in Google drive do the following to set it up.
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

command JsonPretty execute "%!python -m json.tool"

"============================================================================
" Allow saving of files as sudo when I forgot to start vim using sudo.
"============================================================================

cmap w!! w !sudo tee > /dev/null %

"============================================================================
" Good Sources
"============================================================================

" https://github.com/whiteinge/dotfiles
" https://github.com/christoomey/dotfiles

abbreviate decleration declaration
abbreviate Decleration Declaration
abbreviate enqueries enquiries
abbreviate Enqueries Enquiries
abbreviate enquery enquiry
abbreviate Enquery Enquiry
abbreviate enqueryies enquiries
abbreviate enqueryies enquiries
abbreviate Enqueryies Enquiries
abbreviate Enqueryies Enquiries
abbreviate enquires enquiries
abbreviate Enquires Enquiries
abbreviate enquries enquiries
abbreviate Enquries Enquiries
abbreviate im I'm
abbreviate invoce invoke
abbreviate nuget NuGet
abbreviate Nuget NuGet
abbreviate Optimoze Optimize
abbreviate optimoze optimize
abbreviate powershell PowerShell
abbreviate Powershell PowerShell
abbreviate succes success
abbreviate Succes Success
abbreviate successfuly successfully
abbreviate Successfuly Successfully
abbreviate suces success
abbreviate Suces Success
abbreviate sucesful successful
abbreviate Sucesful Successful
abbreviate sucesfully successfully
abbreviate Sucesfully Successfully
abbreviate sucess success
abbreviate Sucess Success
abbreviate sucessful successful
abbreviate Sucessful Successful
abbreviate sucessfull successful
abbreviate Sucessfull Successful
abbreviate sucessfuly successfully
abbreviate Sucessfuly Successfully
abbreviate teh the
abbreviate Teh The
abbreviate tehn then
abbreviate tempary temporary
abbreviate Tempary Temporary
abbreviate tempoary temporary
abbreviate Tempoary Temporary
abbreviate waht what
