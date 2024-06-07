local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    config = function()
      vim.cmd('colorscheme gruvbox-material')
    end
  },
  {
    'jdhao/better-escape.vim',
    lazy = false
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
    config = function()
      require('plugins.file_tree')
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('plugins.treesitter')
    end
  },
  -- Auto completion with LSP
  {
    'ms-jpq/coq_nvim',
    branch = 'coq',
    build = ':COQdeps',
    lazy = false,
    dependencies = {
      {
        'ms-jpq/coq.artifacts',
        branch = 'artifacts',
        -- LSP
        { 'Hoffs/omnisharp-extended-lsp.nvim' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'neovim/nvim-lspconfig' },
        -- Debugger
        {
          'rcarriga/nvim-dap-ui',
          dependencies = {
            { 'mfussenegger/nvim-dap' },
            { 'nvim-neotest/nvim-nio' },
          },
        },
      }
    },
    init = function()
      vim.g.coq_settings = { auto_start = 'shut-up', keymap = { manual_complete = '<C-E>' } }
    end,
    config = function()
      require('plugins.lsp').setup(
        require('mason'),
        require('mason-lspconfig'),
        require('coq'),
        require('lspconfig')
      )
      -- Is needed since we depend on mason for the debugger
      require('plugins.debugger').setup(require('dapui'), require('dap'), require('mason-registry'))
    end

  },
  {
    'junegunn/fzf.vim',
    dependencies = {
      'junegunn/fzf',
      build = function()
        vim.fn['fzf#install']()
      end
    },
    config = function()
      require('plugins.file_search')
    end
  }
})
