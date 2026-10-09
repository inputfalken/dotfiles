return {
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('gruvbox-material')
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { options = { theme = 'gruvbox-material' } }
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
  { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} }, -- LSP progress, e.g. Roslyn loading a solution.
}
