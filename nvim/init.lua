vim.loader.enable()

require('settings')
require('bindings')
require('lsp')

-- Bootstrap lazy.nvim, see https://lazy.folke.io/installation.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error(string.format('Failed to clone lazy.nvim:\n%s', output))
  end
end
vim.opt.rtp:prepend(lazypath)

-- Every file in `lua/plugins/` returns a plugin spec.
require('lazy').setup({ spec = { { import = 'plugins' } } })
