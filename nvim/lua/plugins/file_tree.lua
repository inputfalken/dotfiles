return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false, -- Replaces netrw, so it must be loaded to open directories.
  keys = {
    { '<Leader>fs', '<Cmd>NvimTreeToggle<CR>', desc = 'File system' },
  },
  opts = {
    sort = {
      sorter = 'case_sensitive',
    },
    renderer = {
      group_empty = true,
      highlight_git = 'name',
      highlight_diagnostics = 'name',
    },
    diagnostics = {
      enable = true,
      show_on_dirs = true,
      diagnostic_opts = true,
    },
    modified = {
      enable = true,
    },
    filters = {
      dotfiles = true,
    },
    live_filter = {
      prefix = ' ',
    },
    update_focused_file = {
      enable = true,
    },
  },
}
