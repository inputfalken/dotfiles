vim.keymap.set('n', '<Leader>fe', ':20 Lexplore<CR>') -- Open file explorer
vim.keymap.set('n', '<Leader>P', '\"0P')              -- Paste the last yanked item
vim.keymap.set('n', '<Leader>ev', function()
  vim.cmd('vsplit ~/AppData/Local/nvim/init.lua')
  vim.cmd('lchdir ~/AppData/Local/nvim/')
end)
vim.keymap.set('n', '<Leader>sv', ':so ~/AppData/Local/nvim/init.lua<CR>')
