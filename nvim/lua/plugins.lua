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

require('lazy').setup({
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('gruvbox-material')
    end
  },
  {
    'max397574/better-escape.nvim',
    opts = {
      default_mappings = false,
      mappings = { i = { j = { k = '<Esc>' } } }
    }
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<Leader>f', group = 'Find' },
        { '<Leader>g', group = 'Go to' },
        { '<Leader>h', group = 'Git hunk' },
      }
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map(']h', function() gitsigns.nav_hunk('next') end, 'Next git hunk')
        map('[h', function() gitsigns.nav_hunk('prev') end, 'Previous git hunk')
        map('<Leader>hp', gitsigns.preview_hunk, 'Preview hunk')
        map('<Leader>hs', gitsigns.stage_hunk, 'Stage hunk')
        map('<Leader>hr', gitsigns.reset_hunk, 'Reset hunk')
        map('<Leader>hb', gitsigns.blame_line, 'Blame line')
      end
    }
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
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('plugins.treesitter').setup()
    end
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('plugins.lsp').setup()
    end
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'neovim/nvim-lspconfig' }
    },
    opts = {
      ensure_installed = {
        'roslyn_ls',
        'lua_ls',
        'powershell_es'
      }
    }
  },
  {
    -- Installs non-LSP tools, mason-lspconfig only handles language servers.
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed = { 'netcoredbg' }
    }
  },
  { 'j-hui/fidget.nvim', opts = {} }, -- LSP progress, e.g. Roslyn loading a solution.
  {
    -- Neovim API completion and type checking for lua_ls when editing this config.
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      }
    }
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      { 'mfussenegger/nvim-dap' },
      { 'nvim-neotest/nvim-nio' },
    },
    config = function()
      require('plugins.debugger').setup(require('dap'), require('dapui'))
    end
  },
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    -- LSP capabilities are registered automatically through `vim.lsp.config('*')`.
    opts = {
      keymap = { preset = 'default' },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        }
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' }
    }
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nsidorenco/neotest-vstest',
    },
    keys = {
      { '<Leader>dt', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug nearest test' },
      { '<Leader>rt', function() require('neotest').run.run() end,                     desc = 'Run nearest test' },
    },
    config = function()
      vim.g.neotest_vstest = {
        dap_settings = {
          type = require('modules.util').dap_adapaters.csharp
        }
      }
      require('neotest').setup({
        adapters = {
          require('neotest-vstest')
        }
      })
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable('make') == 1 end,
      },
    },
    keys = {
      { '<Leader>/',  function() require('telescope.builtin').live_grep() end,  desc = 'Live grep' },
      { '<Leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
      { '<Leader>fh', function() require('telescope.builtin').help_tags() end,  desc = 'Find help' },
      { '<Leader>fb', function() require('telescope.builtin').buffers() end,    desc = 'Find buffers' },
      { '<Leader>gf', function() require('telescope.builtin').git_files() end,  desc = 'Git files' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({})
      pcall(telescope.load_extension, 'fzf')
    end
  },
  {
    -- Queries run through the database's own CLI, e.g. `sqlcmd`, `psql` or `sqlite3`.
    'kristijanhusak/vim-dadbod-ui',
    dependencies = { { 'tpope/vim-dadbod', lazy = true } },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    keys = {
      { '<Leader>db', '<Cmd>DBUIToggle<CR>', desc = 'Toggle database UI' },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { options = { theme = 'gruvbox-material' } }
  }
})
