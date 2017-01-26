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
