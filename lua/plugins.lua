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
      require('plugins.file_tree').setup(require('nvim-tree'))
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('plugins.treesitter').setup(
        require('nvim-treesitter.install'),
        require('nvim-treesitter.configs')
      )
    end
  },
  -- Auto completion with LSP
  {
    'ms-jpq/coq_nvim',
    build = function()
      vim.cmd('COQdeps');
    end,
    branch = 'coq',
    lazy = false,
    dependencies = {
      {
        'ms-jpq/coq.artifacts',
        branch = 'artifacts',
        -- LSP
        { 'Hoffs/omnisharp-extended-lsp.nvim' },
        {
          'neovim/nvim-lspconfig',
          config = function()
            require('plugins.lsp').setup(
              require('coq'),
              require('lspconfig')
            )
          end
        },
        {
          'williamboman/mason-lspconfig.nvim',
          opts = {
            ensure_installed = {
              'tsserver',
              'omnisharp',
              'lua_ls',
              'powershell_es'
            }
          },
          config = function(_, opts)
            require('mason-lspconfig').setup(opts);
          end,
          dependencies = {
            {
              'williamboman/mason.nvim',
              build = ':MasonUpdate',
              config = function()
                require('mason').setup()
              end
            }
          }
        },
        {
          'rcarriga/nvim-dap-ui',
          dependencies = {
            { 'mfussenegger/nvim-dap' },
            { 'nvim-neotest/nvim-nio' },
            config = function()
              -- Is needed since we depend on mason for the debugger
              require('plugins.debugger').setup(
                require('dapui'),
                require('dap'),
                require('mason-registry')
              )
            end
          },
        },
      }
    },
    init = function()
      vim.g.coq_settings = { auto_start = 'shut-up', keymap = { manual_complete = '<C-E>' } }
    end,

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
