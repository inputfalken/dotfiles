-- Editing {
vim.keymap.set('n', '<Leader>P', '"0P', { desc = 'Paste last yank' })
-- }

-- Search {
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
-- }

-- Terminal {
-- Esc leaves terminal mode like insert mode, so windows can be switched; Claude Code needs Esc itself, so it keeps it and jk leaves instead.
local function has_claude_descendant(pid)
  return vim.iter(vim.api.nvim_get_proc_children(pid)):any(function(child)
    local process = vim.api.nvim_get_proc(child)
    return (process and process.name:lower():match('^claude') ~= nil) or has_claude_descendant(child)
  end)
end

vim.keymap.set('t', '<Esc>', function()
  local job_pid = vim.b.terminal_job_pid
  return job_pid and has_claude_descendant(job_pid) and '<Esc>' or '<C-\\><C-n>'
end, { expr = true, desc = 'Leave terminal mode, or send Esc to Claude Code' })
-- }

-- Config {
vim.keymap.set('n', '<Leader>ev', function()
  local nvim_directory = vim.fn.stdpath('config')
  vim.cmd.vsplit(vim.fs.joinpath(nvim_directory, 'init.lua'))
  vim.cmd.lchdir(nvim_directory)
end, { desc = 'Edit Neovim config' })
-- }
