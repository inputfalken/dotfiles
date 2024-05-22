--vim.opt.autochdir = true;

-- leader key {
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- }
vim.opt.hidden = true -- Change buffer without saving

vim.g.python_host_prog = 'C:\\Program Files\\Python312\\python'
vim.g.python3_host_prog = 'C:\\Program Files\\Python312\\python'

-- powershell core as terminal
vim.opt.shell = 'pwsh'
vim.opt.shellcmdflag = '-NonInteractive -NoProfile -NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[\'Out-File:Encoding\']=\'utf8\';$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText;'
vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''


-- Set encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
--

-- Enable spelling check for commit message buffer
vim.api.nvim_create_autocmd(
  'FileType', {
    pattern = 'gitcommit',
    callback = function() vim.opt_local.spell = true end
  }
)

vim.opt.path = vim.opt.path + '**' -- Perform recursive search when using find command.
-- https://github.com/nvim-zh/better-escape.vim {
vim.g.better_escape_shortcut = 'jk'
-- 'inoremap jk <esc>' is  an alternative if the plugin is not available
-- }

vim.opt.dictionary = 'spell'   -- Complete words from the spelling dict.
vim.keymap.set('n', 'Y', 'y$') -- Make yank consistent commands such as 'D'.

-- Move by line on the screen rather than by line in the file {
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
-- }

-- Indent Settings {
vim.opt.copyindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.autoindent = true -- Copy the previous indentation on auto indenting
vim.opt.shiftround = true -- Use multiple of shift width when indenting with '<' and '>'
-- }

-- Line Settings {
vim.opt.number = true -- Enable line numbers
vim.opt.scrolloff = 5 -- Sets the amount of rows before scrolling kicks in file.
vim.wo.wrap = false   -- Disables wrapping lines to fit monitor.
-- }

-- File search {
vim.opt.ignorecase = true -- Disables case sensitivity
vim.opt.smartcase = true  -- Enables case sensitivity when casing switches in search string.
vim.opt.hlsearch = true   -- Highlight searches.
vim.opt.incsearch = true  -- show matches for each keystroke
-- }

-- Pair chars {
vim.opt.matchpairs = vim.opt.matchpairs + '<:>' -- Adds < & > as a pair
vim.opt.showmatch = true                        -- Show matching pairs
-- }

vim.opt.cpoptions = vim.opt.cpoptions + '$' -- Appends a '$' where changes are applied.
vim.opt.showmode = true                     -- Show the current mode
vim.opt.mousehide = true                    -- Hide the mouse pointer while typing
