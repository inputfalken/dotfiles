-- leader key {
vim.g.mapleader = ' ';
vim.g.maplocalleader = ' ';
-- }
vim.opt.hidden = true;                                -- Change buffer without saving

vim.keymap.set('n', '<Leader>fe', ':20 Lexplore<CR>') -- Open file explorer
vim.keymap.set('n', '<Leader>P', '\"0P')              -- Paste the last yanked item
vim.keymap.set('n', '<Leader>ev', ':e ~/AppData/Local/nvim/init.lua<CR>')
vim.keymap.set('n', '<Leader>sv', ':so ~/AppData/Local/nvim/init.lua<CR>')
-- python configuration {
vim.g.python_host_prog = 'C:\\Program Files\\Python312\\python';
vim.g.python3_host_prog = 'C:\\Program Files\\Python312\\python';
-- }

-- powershell core as terminal
vim.opt.shell = 'pwsh';
vim.opt.shellcmdflag =
'-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
vim.opt.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode';
vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode';
vim.opt.shellquote = '';
vim.opt.shellxquote = '';
--

-- Set encoding
vim.opt.encoding = 'utf-8';
vim.opt.fileencoding = 'utf-8';
--

-- Enable spelling check for commit message buffer
vim.api.nvim_create_autocmd(
  'FileType', {
    pattern = 'gitcommit',
    callback = function() vim.opt_local.spell = true end
  }
);

vim.opt.path = vim.opt.path + '**'; -- Perform recursive search when using find command.
-- https://github.com/nvim-zh/better-escape.vim {
vim.g.better_escape_shortcut = 'jk';
-- 'inoremap jk <esc>' is  an alternative if the plugin is not available
-- }

vim.opt.dictionary = 'spell';  -- Complete words from the spelling dict.
vim.keymap.set('n', 'Y', 'y$') -- Make yank consistent commands such as 'D'.

-- Move by line on the screen rather than by line in the file {
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
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
vim.wo.wrap = false; -- Disables wrapping lines to fit monitor.
-- }

-- File search {
vim.opt.ignorecase = true; -- Disables case sensitivity
vim.opt.smartcase = true;  -- Enables case sensitivity when casing switches in search string.
vim.opt.hlsearch = true;   -- Highlight searches.
vim.opt.incsearch = true;  -- show matches for each keystroke
-- }

-- Pair chars {
vim.opt.matchpairs = vim.opt.matchpairs + '<:>'; -- Adds < & > as a pair
vim.opt.showmatch = true;                        -- Show matching pairs
-- }

vim.opt.cpoptions = vim.opt.cpoptions + '$'; -- Appends a '$' where changes are applied.
vim.opt.showmode = true;                     -- Show the current mode
vim.opt.mousehide = true;                    -- Hide the mouse pointer while typing

-- Get correct syntax highlighting for .NET configuration files {
vim.api.nvim_create_autocmd(
  { 'BufNewFile', 'BufRead' }, {
    pattern = '*.fsproj, *.csproj, web.config',
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_option(buf, 'filetype', 'xml')
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
  Plug 'sainnhe/gruvbox-material'
  Plug 'nvim-tree/nvim-tree.lua'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
  Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
  Plug 'puremourning/vimspector'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'jdhao/better-escape.vim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'Hoffs/omnisharp-extended-lsp.nvim'
call plug#end()
"}

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

colorscheme gruvbox-material
]])

require 'nvim-treesitter.install'.prefer_git = false
require 'nvim-treesitter.configs'.setup {}

local function on_attach(_, bufnr)
  -- https://github.com/neovim/nvim-lspconfig/blob/master/test/minimal_init.lua

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  -- Mappings.
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', '<Leader>gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<Leader>gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<Leader>fu', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<Leader>gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<Leader>?', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<F2>', function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set('n', '<Leader>gn', function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set('n', '<Leader>gp', function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set('n', '<A-CR>', function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set('n', '<Leader>rc', function() vim.lsp.buf.format({ async = false }) end, opts)
end

vim.g.coq_settings = { auto_start = 'shut-up' }
local lsp = require 'lspconfig';
local coq = require 'coq';
lsp.omnisharp.setup(coq.lsp_ensure_capabilities({
  cmd = { 'C:\\Users\\rober\\.dotnet\\omnisharp-win-x64-net6.0\\OmniSharp.exe' },
  on_attach = on_attach,
  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = true
    }
  },
  handlers = {
    ['textDocument/definition'] = require('omnisharp_extended').definition_handler,
    ['textDocument/typeDefinition'] = require('omnisharp_extended').type_definition_handler,
    ['textDocument/references'] = require('omnisharp_extended').references_handler,
    ['textDocument/implementation'] = require('omnisharp_extended').implementation_handler,
  }
}))

lsp.lua_ls.setup(coq.lsp_ensure_capabilities(
  {
    cmd = { 'lua-language-server' },
    on_attach = on_attach,
    on_init = function(client)
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths here.
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          },
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
          --library = vim.api.nvim_get_runtime_file("", true)
        }
      })
    end,
    settings = {
      Lua = {}
    }
  }
));

require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  }
}
