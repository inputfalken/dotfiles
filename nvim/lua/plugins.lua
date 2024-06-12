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
  { 'jdhao/better-escape.vim' },
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
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      vim.diagnostic.config({
        signs = true,
        underline = true,
        virtual_text = true,
        severity_sort = true,
        update_in_insert = true
      })
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr, client = args.buf, vim.lsp.get_client_by_id(args.data.client_id)

          if client.server_capabilities.completionProvider then
            vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
          end
          if client.server_capabilities.definitionProvider then
            vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
          end

          local floatOpts = {
            focusable = false,
            close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
          }

          -- Open diagnostic pop-up when hovering.
          -- `vim.o.updatetime = 100` will affect how fast the window is shown, default is 4000.
          vim.api.nvim_create_autocmd('CursorHold', {
            buffer = bufnr,
            callback = function()
              vim.diagnostic.open_float(nil, floatOpts)
            end
          })

          -- Mappings.
          local opts = { buffer = bufnr, noremap = true, silent = true }

          local builtin = require('telescope.builtin')
          if (builtin ~= nil) then
            if (client ~= nil and client.config.name == 'omnisharp' and require('omnisharp_extended') ~= nil) then
              vim.keymap.set('n', '<Leader>gd', require('omnisharp_extended').telescope_lsp_definition, opts)
              vim.keymap.set('n', '<Leader>fu', require('omnisharp_extended').telescope_lsp_references, opts)
              vim.keymap.set('n', '<Leader>gi', require('omnisharp_extended').telescope_lsp_implementation, opts)
            else
              vim.keymap.set('n', '<Leader>gd', builtin.lsp_definitions, opts)
              vim.keymap.set('n', '<Leader>fu', builtin.lsp_references, opts)
              vim.keymap.set('n', '<Leader>gi', builtin.lsp_implementations, opts)
            end
            vim.keymap.set('n', '<Leader>gD', builtin.lsp_type_definitions, opts)
          else
            vim.keymap.set('n', '<Leader>gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', '<Leader>fu', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<Leader>gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', '<Leader>gi', vim.lsp.buf.implementation, opts)
          end
          vim.keymap.set('n', '<Leader>?', function()
            if (vim.diagnostic.open_float(nil, floatOpts) ~= nil) then
              return
            end
            if (vim.lsp.buf.hover() ~= nil) then
              return
            end
          end, opts)
          vim.keymap.set({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<Leader>gne', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '<Leader>gpe', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', '<A-CR>', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<Leader>rc', vim.lsp.buf.format, opts)
        end,
      })
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', },
      { 'neovim/nvim-lspconfig' }
    },
    config = function()
      require('mason-lspconfig').setup(
        {
          ensure_installed = {
            'tsserver',
            'omnisharp',
            'lua_ls',
            'powershell_es'
          }
        }
      )
    end
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      { 'mfussenegger/nvim-dap' },
      { 'nvim-neotest/nvim-nio' },
      { 'williamboman/mason.nvim' },
    },
    opts = function()
      return {
        dap_ui = require('dapui'),
        dap = require('dap'),
        mason_registry = require('mason-registry')
      }
    end,
    config = function(_, opts)
      require('plugins.debugger').setup(opts)
    end
  },
  -- Auto completion
  {
    'ms-jpq/coq_nvim',
    build = function()
      vim.cmd('COQdeps');
    end,
    branch = 'coq',
    dependencies = {
      {
        {
          'ms-jpq/coq.artifacts',
          branch = 'artifacts'
        },
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason-lspconfig.nvim' } -- Is Required in order to find LSP's
      }
    },
    opts = function()
      return {
        lsp = require('lspconfig'),
        coq = require('coq')
      }
    end,
    init = function()
      vim.g.coq_settings = { auto_start = 'shut-up', keymap = { manual_complete = '<C-E>' } }
    end,
    config = function(_, opts)
      require('plugins.lsp.typescript').setup(opts)
      require('plugins.lsp.lua').setup(opts)
      require('plugins.lsp.powershell').setup(opts)
      require('plugins.lsp.csharp').setup(opts)
    end
  },
  {
    'Hoffs/omnisharp-extended-lsp.nvim',
    dependencies = {
      { 'ms-jpq/coq_nvim' },
      { 'williamboman/mason-lspconfig.nvim' } -- Is Required in order to find LSP's
    }
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>/', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
    end
  }
}
)
