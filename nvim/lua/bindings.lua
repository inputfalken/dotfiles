vim.keymap.set('n', '<Leader>P', '"0P') -- Paste the last yanked item
vim.keymap.set('n', '<Leader>ev', function()
  local nvim_directory = vim.fn.stdpath('config')
  vim.cmd.vsplit(vim.fs.joinpath(nvim_directory, 'init.lua'))
  vim.cmd.lchdir(nvim_directory)
end)
