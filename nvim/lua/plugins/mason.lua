return {
  -- Server configs in `lsp/`, loaded at startup like before so buffers opened from the command line attach.
  { 'neovim/nvim-lspconfig', lazy = false },
  {
    'mason-org/mason-lspconfig.nvim',
    event = 'VeryLazy',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'neovim/nvim-lspconfig' }
    },
    opts = {
      ensure_installed = {
        'roslyn_ls',
        'lua_ls',
        'powershell_es'
      },
      -- roslyn.nvim runs the Roslyn server instead of nvim-lspconfig's roslyn_ls.
      automatic_enable = { exclude = { 'roslyn_ls' } }
    }
  },
  {
    -- Installs non-LSP tools, mason-lspconfig only handles language servers.
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    event = 'VeryLazy',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed = { 'netcoredbg' }
    }
  },
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
}
