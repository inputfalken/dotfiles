-- leader key {
  vim.g.mapleader = " ";
  vim.g.maplocalleader = " ";
-- }
vim.opt.hidden = true;  -- Change buffer without saving

vim.keymap.set("n", "<Leader>fe", ":20 Lexplore<CR>") -- Open file explorer
vim.keymap.set("n", "<Leader>P", "\"0P") -- Paste the last yanked item
vim.keymap.set("n", "<Leader>ev", ":e ~/AppData/Local/nvim/init.lua<CR>")
vim.keymap.set("n", "<Leader>sv", ":so ~/AppData/Local/nvim/init.lua<CR>")
-- python configuration {
  vim.g.python_host_prog = "C:\\Program Files\\Python312\\python";
  vim.g.python3_host_prog = "C:\\Program Files\\Python312\\python";
-- }

-- powershell core as terminal
  vim.opt.shell = "pwsh";
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode";
  vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode";
  vim.opt.shellquote = "";
  vim.opt.shellxquote = "";
--

-- Set encoding
  vim.opt.encoding = "utf-8";
  vim.opt.fileencoding = "utf-8";
--

-- Enable spelling check for commit message buffer
vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = "gitcommit",
    callback = function () vim.opt_local.spell = true end
  }
);

vim.opt.path = vim.opt.path + "**"; -- Perform recursive search when using find command.
-- https://github.com/nvim-zh/better-escape.vim {
  vim.g.better_escape_shortcut = "jk";
  -- 'inoremap jk <esc>' is  an alternative if the plugin is not available
-- }

vim.opt.dictionary = "spell"; -- Complete words from the spelling dict.
vim.keymap.set("n", "Y", "y$") -- Make yank consistent commands such as 'D'.

-- Move by line on the screen rather than by line in the file {
  vim.keymap.set("n", "j", "gj")
  vim.keymap.set("n", "k", "gk")
-- }

-- Indent Settings {
  vim.opt.copyindent = true;
  vim.opt.expandtab = true;
  vim.opt.tabstop = 2;
  vim.opt.shiftwidth = 2;
  vim.opt.softtabstop = 2;
  vim.opt.autoindent = true; -- Copy the previous indentation on auto indenting
  vim.opt.shiftround = true; -- Use multiple of shift width when indenting with '<' and '>'
-- }

-- Line Settings {
  vim.opt.number = true; -- Enable line numbers
  vim.opt.scrolloff = 5; -- Sets the amount of rows before scrolling kicks in file.
-- }

-- File search {
  vim.opt.ignorecase = true; -- Disables case sensitivity
  vim.opt.smartcase = true; -- Enables case sensitivity when casing switches in search string.
  vim.opt.hlsearch = true; -- Highlight searches.
  vim.opt.incsearch = true; -- show matches for each keystroke
-- }

-- Pair chars {
  vim.opt.matchpairs = vim.opt.matchpairs + "<:>"; -- Adds < & > as a pair
  vim.opt.showmatch = true; -- Show matching pairs
-- }

vim.opt.cpoptions = vim.opt.cpoptions + "$"; -- Appends a '$' where changes are applied.
vim.opt.showmode = true; -- Show the current mode
vim.opt.mousehide = true; -- Hide the mouse pointer while typing


-- Get correct syntax highlighting for .NET configuration files {
vim.api.nvim_create_autocmd(
  {"BufNewFile", "BufRead"}, {
    pattern = "*.fsproj, *.csproj, web.config",
    callback = function ()
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_option(buf, "filetype", "xml")
    end
  }
);
-- }


-- Plugged {



-- }

vim.cmd([[
"============================================================================
" TODO put in seperate file
"============================================================================

call plug#begin()
  Plug 'nvim-tree/nvim-tree.lua'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'OmniSharp/omnisharp-vim'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'dense-analysis/ale'
  Plug 'puremourning/vimspector'
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
  Plug 'Hoffs/omnisharp-extended-lsp.nvim'
call plug#end()
"}


" TODO structure
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"

  "Plug 'puremourning/vimspector'
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
  let g:OmniSharp_server_use_net6 = 1
  let g:OmniSharp_selector_ui = 'fzf'


  augroup omnisharp_commands
    autocmd!
    " Show type information automatically when the cursor stops moving.
    " Note that the type is echoed to the Vim command line, and will overwrite
    " any other messages in this space including e.g. ALE linting messages.
    autocmd CursorHold *.cs OmniSharpTypeLookup


    autocmd FileType cs nmap <silent> <buffer> <Leader>pd <Plug>(omnisharp_preview_definition)
    autocmd FileType cs nmap <silent> <buffer> <Leader>pi <Plug>(omnisharp_preview_implementations)

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

    " The following commands are contextual, based on the cursor position.
    autocmd FileType cs nmap <silent> <buffer> <Leader>gd <Plug>(omnisharp_go_to_definition)
    autocmd FileType cs nmap <silent> <buffer> <Leader>gi <Plug>(omnisharp_find_implementations)
    autocmd FileType cs nmap <silent> <buffer> <Leader>fu <Plug>(omnisharp_find_usages)

    "" Hoffs/omnisharp-extended-lsp.nvim
    "autocmd FileType cs nnoremap <Leader>gd <cmd>lua require('omnisharp_extended').lsp_definition()<cr>
    "autocmd FileType cs nnoremap <Leader>fu <cmd>lua require('omnisharp_extended').lsp_references()<cr>
    "autocmd FileType cs nnoremap <Leader>gi <cmd>lua require('omnisharp_extended').lsp_implementation()<cr>

  augroup END
"C# }
  augroup other_commands
    autocmd!
    autocmd FileType javascript nmap <Leader>gd :ALEGoToDefinition<CR>
    autocmd FileType javascriptreact nmap <Leader>gd :ALEGoToDefinition<CR>
    autocmd FileType typescript nmap <Leader>gd :ALEGoToDefinition<CR>
    autocmd FileType typescriptreact nmap <Leader>gd :ALEGoToDefinition<CR>
    if(&ft!='cs' && &ft!='cshtml')
      noremap <Leader>rc :ALEFix<CR>
    endif
  augroup end


" ALE {
  let js_fixers = ['prettier', 'eslint']
  let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'javascript': js_fixers,
  \   'javascript.jsx': js_fixers,
  \   'typescript': js_fixers,
  \   'typescriptreact': js_fixers,
  \   'css': ['prettier'],
  \   'json': ['prettier'],
  \}
  let g:ale_fix_on_save = 1
" }
" coc-snippets {
  inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#_select_confirm() :
        \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        \ CheckBackspace() ? "\<TAB>" :
        \ coc#refresh()

  function! CheckBackspace() abort
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

" TODO put in C:\Users\roban2\AppData\Local\nvim\ginit.vim
" GUI logic{
  "Guifont CaskaydiaCove NF:H12:l
"}
]])

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "sainnhe/gruvbox-material",
  "jdhao/better-escape.vim"
}, opts)
