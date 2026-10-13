-- Editing {
vim.keymap.set('n', '<Leader>P', '"0P', { desc = 'Paste last yank' })
-- }

-- Search {
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
-- }

-- Terminal {
-- Esc leaves terminal mode like insert mode, so windows can be switched; programs in the terminal no longer get Esc.
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Leave terminal mode' })
-- }

-- Config {
vim.keymap.set('n', '<Leader>ev', function()
  local nvim_directory = vim.fn.stdpath('config')
  vim.cmd.vsplit(vim.fs.joinpath(nvim_directory, 'init.lua'))
  vim.cmd.lchdir(nvim_directory)
end, { desc = 'Edit Neovim config' })
-- }
