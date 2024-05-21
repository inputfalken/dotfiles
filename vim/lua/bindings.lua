vim.keymap.set('n', '<Leader>fe', ':20 Lexplore<CR>') -- Open file explorer
vim.keymap.set('n', '<Leader>P', '\"0P')              -- Paste the last yanked item
local nvim_directory = os.getenv('LOCALAPPDATA') .. '\\nvim'
local nvim_init_file = nvim_directory .. '\\init.lua'
vim.keymap.set('n', '<Leader>ev', function()
  vim.cmd(string.format('vsplit %s', nvim_init_file))
  vim.cmd(string.format('lchdir %s', nvim_directory))
end)
vim.keymap.set('n', '<Leader>sv', function()
  vim.cmd(string.format('source %s', nvim_init_file))
end)
