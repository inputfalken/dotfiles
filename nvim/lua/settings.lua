-- leader key {
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- }

-- Disable netrw before any plugin loads, nvim-tree replaces it.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- powershell core as terminal
vim.opt.shell = 'pwsh'
vim.opt.shellcmdflag =
'-NonInteractive -NoProfile -NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[\'Out-File:Encoding\']=\'utf8\';$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText;'
vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

local profile_path = require('modules.util').HOME_PATH
    .. [[\Documents\PowerShell\Microsoft.PowerShell_profile.ps1]]
vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = 'ps1',
    callback = function(ev)
      if (profile_path ~= ev.file) then
        return
      end
      vim.cmd.lchdir(require('modules.util').get_directory(ev.file))
    end
  }
)

-- Enable spelling check for commit message buffer
vim.api.nvim_create_autocmd(
  'FileType', {
    pattern = 'gitcommit',
    callback = function() vim.opt_local.spell = true end
  }
)

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end
})

vim.opt.path = vim.opt.path + '**' -- Perform recursive search when using find command.
vim.opt.dictionary = 'spell' -- Complete words from the spelling dict.

-- Indent Settings {
vim.opt.copyindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.shiftround = true -- Use multiple of shift width when indenting with '<' and '>'
-- }

-- Line Settings {
vim.opt.number = true       -- Enable line numbers
vim.opt.scrolloff = 5       -- Sets the amount of rows before scrolling kicks in file.
vim.opt.wrap = false        -- Disables wrapping lines to fit monitor.
vim.opt.signcolumn = 'yes'  -- Keep the sign column so diagnostics don't shift the text.
-- }

-- File search {
vim.opt.ignorecase = true      -- Disables case sensitivity
vim.opt.smartcase = true       -- Enables case sensitivity when casing switches in search string.
vim.opt.inccommand = 'split'   -- Preview substitutions in a split.
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>') -- Clear search highlight.
-- }

-- Pair chars {
vim.opt.matchpairs = vim.opt.matchpairs + '<:>' -- Adds < & > as a pair
vim.opt.showmatch = true                        -- Show matching pairs
-- }

vim.opt.cpoptions = vim.opt.cpoptions + '$' -- Appends a '$' where changes are applied.
vim.opt.termguicolors = true
vim.opt.undofile = true                     -- Persist undo history between sessions.
vim.opt.updatetime = 250                    -- Delay before 'CursorHold' fires (diagnostic pop-up).
vim.opt.splitright = true
vim.opt.splitbelow = true
