-- leader key {
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- }

-- Disabled built-ins {
-- Disable netrw before any plugin loads, nvim-tree replaces it.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- No plugin is written for the remote plugin hosts.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
-- }

-- powershell core as terminal {
-- :terminal starts this without 'shellcmdflag', so the profile loads; -NoLogo skips the banner.
vim.opt.shell = 'pwsh -NoLogo'
vim.opt.shellcmdflag =
  "-NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText;"
vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

-- Started from pwsh, the inherited module path lists PowerShell 7 modules first. Windows PowerShell, which plugins
-- such as mssql.nvim run, then loads PowerShell 7's `Microsoft.PowerShell.Archive` and `Expand-Archive` fails.
if vim.env.PSModulePath then
  vim.env.PSModulePath = table.concat(
    vim.tbl_filter(function(path)
      return path:lower():find('[\\/]powershell[\\/]') == nil
    end, vim.split(vim.env.PSModulePath, ';', { trimempty = true })),
    ';'
  )
end

local settings_group = vim.api.nvim_create_augroup('Settings', { clear = true })

-- Editing the PowerShell profile works from its directory, e.g. for `:e profile.local.ps1`.
local profile_path =
  vim.fs.normalize(vim.fs.joinpath(vim.uv.os_homedir(), 'Documents/PowerShell/Microsoft.PowerShell_profile.ps1'))
vim.api.nvim_create_autocmd('FileType', {
  group = settings_group,
  pattern = 'ps1',
  callback = function(ev)
    if vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf)) ~= profile_path then
      return
    end
    vim.cmd.lchdir(vim.fs.dirname(profile_path))
  end,
})
-- }

-- Terminal {
local terminal_group = vim.api.nvim_create_augroup('PwshTerminal', { clear = true })

-- New terminals are ready to type into.
vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  command = 'startinsert',
})

-- Neovim closes a shell terminal that exits without an error by comparing its command with 'shell', which never
-- matches on Windows where the command holds the resolved pwsh.EXE path.
vim.api.nvim_create_autocmd('TermClose', {
  group = terminal_group,
  nested = true,
  callback = function(event)
    if vim.v.event.status ~= 0 then
      return
    end
    local shell = vim.split(vim.o.shell, ' ', { trimempty = true })
    shell[1] = vim.fn.exepath(shell[1])
    local argv = vim.api.nvim_get_chan_info(vim.bo[event.buf].channel).argv or {}
    if vim.deep_equal(argv, shell) then
      vim.api.nvim_buf_delete(event.buf, { force = true })
    end
  end,
})

-- The terminal window follows the shell's directory, see `:h terminal-osc7`. oh-my-posh reports it as OSC 9;9,
-- which Windows Terminal also reads for duplicating tabs and panes.
vim.api.nvim_create_autocmd('TermRequest', {
  group = terminal_group,
  callback = function(event)
    local dir = event.data.sequence:match('^\027%]9;9;(.+)$')
    if dir and vim.fn.isdirectory(dir) == 1 and vim.api.nvim_get_current_buf() == event.buf then
      vim.cmd.lcd(dir)
    end
  end,
})
-- }

-- Autocommands {
-- Enable spelling check for commit message buffer
vim.api.nvim_create_autocmd('FileType', {
  group = settings_group,
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd('TextYankPost', {
  group = settings_group,
  callback = function()
    vim.hl.on_yank()
  end,
})
-- }

-- Completion sources {
vim.opt.path:append('**') -- Perform recursive search when using find command.
vim.opt.dictionary = 'spell' -- Complete words from the spelling dict.
-- }

-- Indent Settings {
-- Defaults for projects without an .editorconfig, which Neovim applies per buffer, see `:h editorconfig`.
vim.opt.copyindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.shiftround = true -- Use multiple of shift width when indenting with '<' and '>'

-- The line past 'textwidth' (.editorconfig's max_line_length) shows while typing. ModeChanged rather than
-- InsertLeave, which <C-c> skips.
vim.api.nvim_create_autocmd('ModeChanged', {
  group = settings_group,
  callback = function()
    local colorcolumn = vim.v.event.new_mode:match('^i') and '+1' or ''
    if vim.wo.colorcolumn ~= colorcolumn then
      vim.wo.colorcolumn = colorcolumn
    end
  end,
})
-- }

-- Line Settings {
vim.opt.number = true -- Enable line numbers
vim.opt.scrolloff = 5 -- Sets the amount of rows before scrolling kicks in file.
vim.opt.wrap = false -- Disables wrapping lines to fit monitor.
vim.opt.signcolumn = 'yes' -- Keep the sign column so diagnostics don't shift the text.
-- }

-- File search {
vim.opt.ignorecase = true -- Disables case sensitivity
vim.opt.smartcase = true -- Enables case sensitivity when casing switches in search string.
vim.opt.inccommand = 'split' -- Preview substitutions in a split.
-- }

-- Pair chars {
vim.opt.matchpairs:append('<:>') -- Adds < & > as a pair
vim.opt.showmatch = true -- Show matching pairs
-- }

-- Filetypes {
-- MSBuild targets, so treesitter and lemminx treat them as XML (Neovim already does .slnx and the Directory.Build.* files).
vim.filetype.add({ extension = { targets = 'xml' } })
-- }

-- Folding {
-- Folds follow the code's structure: treesitter by default, the language server's ranges once it attaches (lsp.lua).
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99 -- Everything starts unfolded.
vim.opt.foldtext = '' -- A closed fold shows its first line with syntax highlighting.
vim.opt.fillchars:append({ fold = ' ' })
-- }

-- Editor {
vim.opt.cpoptions:append('$') -- Appends a '$' where changes are applied.
vim.opt.termguicolors = true
-- Neovim's default, except a bar in terminal mode like Windows Terminal's cursor.
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:ver25-blinkon500-blinkoff500-TermCursor'
vim.opt.undofile = true -- Persist undo history between sessions.
vim.opt.updatetime = 250 -- Delay before 'CursorHold' fires (diagnostic pop-up).
vim.opt.splitright = true
vim.opt.splitbelow = true
-- }

-- Auto reload {
-- Buffers follow changes other programs (e.g. an agent in a terminal split) make to their files. 'autoread' only acts
-- on `:checktime`, so a watcher per file buffer runs it as soon as the file changes, focus or not.
vim.opt.autoread = true
local reload_group = vim.api.nvim_create_augroup('AutoReload', { clear = true })
local watchers = {}

local function unwatch(buf)
  local watcher = watchers[buf]
  if not watcher then
    return
  end
  watcher:close()
  watchers[buf] = nil
end

local function watch(buf)
  unwatch(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= '' or path == '' or not vim.uv.fs_stat(path) then
    return
  end
  local watcher = vim.uv.new_fs_event()
  watchers[buf] = watcher
  watcher:start(
    path,
    {},
    vim.schedule_wrap(function(err)
      if err or not vim.api.nvim_buf_is_valid(buf) then
        unwatch(buf)
        return
      end
      vim.cmd.checktime(buf)
    end)
  )
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufFilePost' }, {
  group = reload_group,
  callback = function(ev)
    watch(ev.buf)
  end,
})

vim.api.nvim_create_autocmd('BufUnload', {
  group = reload_group,
  callback = function(ev)
    unwatch(ev.buf)
  end,
})

-- Covers files the watcher misses, e.g. created after the buffer was opened.
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'TermLeave' }, {
  group = reload_group,
  callback = function()
    if vim.fn.getcmdwintype() ~= '' then
      return
    end
    vim.cmd.checktime()
  end,
})
-- }

-- Project config {
-- Load a project-local `.nvim.lua` (ignored through the global gitignore). Neovim asks once per file before
-- trusting it, see `:h :trust`. Projects can set e.g. `vim.g.telescope_ignore_paths = { 'src/vendor' }` to hide
-- folders from telescope or `vim.g.roslyn_solution = 'App.sln'` to pick a solution.
vim.opt.exrc = true
-- }
