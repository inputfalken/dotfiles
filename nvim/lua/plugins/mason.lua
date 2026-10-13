return {
  -- Server definitions (`lsp/*.lua`) that mason-lspconfig enables; must be on the runtimepath before mason-lspconfig loads.
  { 'neovim/nvim-lspconfig' },
  {
    'mason-org/mason-lspconfig.nvim',
    event = 'VeryLazy',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
    },
    opts = {
      ensure_installed = {
        'roslyn_ls',
        'lua_ls',
        'powershell_es',
        'vtsls',
        'eslint',
        'cssls',
        'jsonls',
        'yamlls',
        'lemminx',
      },
      -- roslyn.nvim runs the Roslyn server instead of nvim-lspconfig's roslyn_ls.
      automatic_enable = { exclude = { 'roslyn_ls' } },
    },
  },
  {
    -- Installs non-LSP tools, mason-lspconfig only handles language servers.
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    event = 'VeryLazy',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed = { 'netcoredbg', 'stylua', 'prettier', 'biome' },
    },
  },
  -- JSON and YAML schemas by file name (appsettings.json, package.json, Azure Pipelines, ...), see after/lsp/.
  { 'b0o/SchemaStore.nvim', lazy = true },
  {
    -- Neovim API completion and type checking for lua_ls when editing this config.
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
}
